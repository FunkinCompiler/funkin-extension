package mikolka;

import mikolka.vscode.definitions.DisposableProvider;
import vscode.Disposable;
import mikolka.vscode.providers.StartupInit;
import mikolka.vscode.providers.mode1.TaskRegistry;
import mikolka.vscode.providers.mode1.DebuggerSetup;
import mikolka.vscode.providers.mode2.VsHaxeProvider;
import mikolka.vscode.providers.ComandRegistry;
import mikolka.vscode.providers.DiagnosticRegistry;

class Main {
	public static var isMode2Active(get, never):Bool;

	public static function get_isMode2Active() {
		return mode2Providers != null;
	}

	public static var isMode1Active(get, never):Bool;

	public static function get_isMode1Active() {
		return mode1Providers != null;
	}

	public static var mode2Providers:Null<Array<DisposableProvider>> = null;
	public static var mode1Providers:Null<Array<DisposableProvider>> = null;
	public static var globalProviders:Null<Array<DisposableProvider>> = null;

	@:expose("activate")
	static function activate(context:vscode.ExtensionContext) {
		trace("Active");
		var registry = new CommandRegistry(context);

		registerModeChecks(context);
		scanForModeChanges(context);
	}

	static function activateGlobal(context:vscode.ExtensionContext):Array<DisposableProvider> {

		var diagnostics = new DiagnosticRegistry(context);
		var startup = new StartupInit(context);
		startup.runStartupChecks();
		return [diagnostics, startup];
	}

	static function activateMode1(context:vscode.ExtensionContext):Array<DisposableProvider> {
		trace("Mode1");
		var tasks = new TaskRegistry(context);
		var debugger = new DebuggerSetup(context);
		return [tasks, debugger];
	}

	static function activateMode2(context:vscode.ExtensionContext):Array<DisposableProvider> {
		trace("Mode2");
		var haxeIntegration = new VsHaxeProvider(context);
		return [haxeIntegration];
	}

	private static function registerModeChecks(context:vscode.ExtensionContext) {
		Vscode.workspace.onDidChangeWorkspaceFolders(e -> {
			scanForModeChanges(context);
		});
	}
	private static function scanForModeChanges(context:vscode.ExtensionContext) {
		Vscode.workspace.findFiles("_polymod_meta.json").then(s -> {
			trace(s);
				if (s.length > 0 && !isMode2Active)
					mode2Providers = activateMode2(context);
				else if (isMode2Active) {
					for (x in mode2Providers) {
						x.dispose();
					}
					mode2Providers = null;
				};
				chackGlobalHook(context);
			});
			Vscode.workspace.findFiles("funk.cfg").then(s -> {
				trace(s);
				if (s.length > 0 && !isMode1Active)
					mode1Providers = activateMode1(context);
				else if (isMode1Active) {
					for (x in mode1Providers) {
						x.dispose();
					}
					mode1Providers = null;
				};
				chackGlobalHook(context);
			});
			
	}
	private static function chackGlobalHook(context:vscode.ExtensionContext){
		if ((isMode2Active || isMode1Active) && globalProviders == null) {
				globalProviders = activateGlobal(context);
			} else if ((!isMode2Active && !isMode1Active) && globalProviders != null) {
				for (x in globalProviders)
					x.dispose();
				globalProviders = null;
			}
	}
}
