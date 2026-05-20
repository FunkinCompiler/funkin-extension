package mikolka;

import mikolka.helpers.ModeManager.FilePatternMode;
import mikolka.vscode.definitions.DisposableProvider;
import vscode.Disposable;
import mikolka.vscode.providers.StartupInit;
import mikolka.vscode.providers.mode1.TaskRegistry;
import mikolka.vscode.providers.mode1.DebuggerSetup;
import mikolka.vscode.providers.VsHaxeProvider;
import mikolka.vscode.providers.ComandRegistry;
import mikolka.vscode.providers.diagnostics.DiagnosticRegistry;

class Main {
	public static final FUNK_PROJECT = "mode1";
	public static final VSLICE_MOD = "mode2";
	public static final FUNKIN_ASSETS = "mode3";
	public static var modules:ModeManager;

	@:expose("activate")
	static function activate(context:vscode.ExtensionContext) {
		trace("Active");
		modules = new ModeManager();
		modules.registerMode(new FilePatternMode(
			FUNK_PROJECT,
			"funk.cfg",
			context -> {
				trace("Mode1 activate");
				var tasks = new TaskRegistry(context);
				return [tasks];
			},
			providers -> trace("Mode1 deactivated")
		));

		// Mode2
		modules.registerMode(new FilePatternMode(
			VSLICE_MOD,
			"_polymod_meta.json",
			context -> {
				trace("Mode2 activate");
				// return providers for mode2 as you add them
				return [];
			}
		));		
		modules.registerMode(new FilePatternMode(
			FUNKIN_ASSETS,
			"exclude/data/credits.json",
			context -> {
				trace("Mode3 activate");
				// return providers for mode2 as you add them
				return [];
			}
		));
		modules.activateGlobal = context -> {
			var diagnostics = new DiagnosticRegistry(context);
			var startup = new StartupInit(context);
			var haxeIntegration = new VsHaxeProvider(context);
			var debugger = new DebuggerSetup(context);
			startup.runStartupChecks();
			return [diagnostics, startup,haxeIntegration,debugger];
		}

		var command = new CommandRegistry(context);
		modules.scanForModeChanges(context);
	}
}
