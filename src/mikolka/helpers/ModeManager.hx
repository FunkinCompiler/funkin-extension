package mikolka.helpers;

import js.lib.Promise;
import mikolka.vscode.definitions.DisposableProvider;
import vscode.Disposable;
import mikolka.vscode.providers.StartupInit;
import mikolka.vscode.providers.VsHaxeProvider;
import mikolka.vscode.providers.diagnostics.DiagnosticRegistry;
import mikolka.vscode.providers.ComandRegistry;
import mikolka.vscode.providers.mode1.TaskRegistry;
import mikolka.vscode.providers.mode1.DebuggerSetup;

typedef ModeCheck = (vscode.ExtensionContext -> Thenable<Array<vscode.Uri>>);

interface IMode {
	function id():String;
	// Called when mode becomes active; return providers to manage
	function activate(context:vscode.ExtensionContext):Array<DisposableProvider>;
	// Called when mode is deactivated with previously returned providers
	function deactivate(providers:Array<DisposableProvider>):Void;
	// How to detect presence of this mode in a workspace
	function detector():ModeCheck;
}

class FilePatternMode implements IMode {
	var _id:String;
	var _pattern:String;
	var _activator:Array<DisposableProvider>->Void;
	var _factory:vscode.ExtensionContext->Array<DisposableProvider>;

	public function new(id:String, pattern:String, factory:vscode.ExtensionContext->Array<DisposableProvider>, deactivator:Array<DisposableProvider>->Void = null) {
		_id = id;
		_pattern = pattern;
		_factory = factory;
		_activator = deactivator == null ? ((_) -> {}) : deactivator;
	}

	public function id() return _id;
	public function activate(context:vscode.ExtensionContext) return _factory(context);
	public function deactivate(providers:Array<DisposableProvider>) {
		for (p in providers) p.dispose();
		_activator(providers);
	}
	public function detector() {
		return (context) -> Vscode.workspace.findFiles(_pattern);
	}
}

class ModeManager {
	public var isModeActive(get, never):Bool;
	public function get_isModeActive() return mapLength(_activeModes) > 0;

	private var _modes:Map<String, IMode> = new Map();
	private var _activeModes:Map<String, Array<DisposableProvider>> = new Map();
	private var _globalProviders:Null<Array<DisposableProvider>> = null;

    public function new() {
        
    }

	public function registerMode(mode:IMode):Void {
		_modes.set(mode.id(), mode);
	}

	public function scanForModeChanges(context:vscode.ExtensionContext):Void {
		for (modeId in _modes.keys()) {
			var mode = _modes.get(modeId);
			mode.detector()(context).then(files -> {
				var active = files.length > 0;
				var currentlyActive = _activeModes.exists(modeId);
				if (active && !currentlyActive) {
					var provs = mode.activate(context);
					_activeModes.set(modeId, provs);
				} else if (!active && currentlyActive) {
					var old = _activeModes.get(modeId);
					mode.deactivate(old);
					_activeModes.remove(modeId);
				}
				_checkGlobalHook(context);
			});
		}
	}

	function _checkGlobalHook(context:vscode.ExtensionContext):Void {
		if ((mapLength(_activeModes) > 0) && _globalProviders == null) {
			_globalProviders = activateGlobal(context);
		} else if ((mapLength(_activeModes) == 0) && _globalProviders != null) {
			for (x in _globalProviders) x.dispose();
			_globalProviders = null;
		}
	}
    function mapLength(it:Map<Any,Any>):Int {
        var i = 0;
        for (x in it.keys()){
            i = i+1;
        }
        return i;
    }

	public dynamic function activateGlobal(context:vscode.ExtensionContext):Array<DisposableProvider> {
        return [];
	}
}
