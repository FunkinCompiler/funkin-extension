package mikolka;

import mikolka.vscode.providers.tasks.CppiaMakeTask;
import thx.semver.Version;
import mikolka.vscode.providers.tasks.PCCopyTask;
import mikolka.vscode.providers.DebuggerSetup;
import mikolka.helpers.ModeManager.FilePatternMode;
import mikolka.vscode.providers.commands.*;
import mikolka.vscode.providers.StartupInit;
import mikolka.vscode.providers.tasks.AdbTask;
import mikolka.vscode.providers.VsHaxeProvider;
import mikolka.vscode.providers.diagnostics.DiagnosticRegistry;

class Main {

	public static final INSTALL_VERSION:Version = Version.stringToVersion("1.1.0");
	public static final MANIFEST_VERSION:String = "1.1.0";

	public static final HAXE_VERSION:String = "v1.1";
    public static final HAXE_GITHUB_TAG:String = "4.3.7-2";

	public static final VSLICE_MOD = "mode2";
	public static final FUNKIN_ASSETS = "mode3";
	public static var modules:ModeManager;

	static function main() {}

	@:expose("activate")
	static function activate(context:vscode.ExtensionContext) {
		trace("Active");
		modules = new ModeManager();
		// Mode2
		modules.registerMode(new FilePatternMode(
			VSLICE_MOD,
			"_polymod_meta.json"
		));		
		modules.registerMode(new FilePatternMode(
			FUNKIN_ASSETS,
			"exclude/ui/credits/credits.json"
		));
		modules.activateGlobal = context -> {
			
			var result = [
				new DiagnosticRegistry(context), 
				new VsHaxeProvider(context),
				new DebuggerSetup(context),
				new AdbTask(context),
				new PCCopyTask(context),
			];
			
			return result;
		}
		var startup = new StartupInit(context);
		
		modules.standbyProviders = [
			startup,
			new HaxelibsFolderCommand(context),
			new NewCommand(context),
			new CppiaMakeTask(context),
			new SetHaxelibCommand(context),
			new SetupCommand(context),
			
		];
		startup.runStartupChecks();
		modules.scanForModeChanges(context);
	}
}
