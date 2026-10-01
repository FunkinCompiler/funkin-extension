package mikolka.vscode.providers;

import mikolka.vscode.definitions.DisposableProvider;
import shared.FunkinPaths;
import sys.FileSystem;
import js.Lib;
import mikolka.config.VsCodeConfig;
import haxe.io.Path;
import vscode.DebugConfiguration;

typedef FNFLaunchRequestArguments = DebugConfiguration & {
	var cwd:String;
	var cmd_prefix:String;
	var execName:String;
	var args:Array<String>;
	var isMobile:Bool;
	var trace:Bool; // if set to true sends trace messages as DebugSession.OutputEvents
}

/**
 * Class responsible for configuring debugger for Friday Night Funkin'.
 * This lets us capture logs and control it's process.
 */
class DebuggerSetup extends DisposableProvider { 

	public function new(context:vscode.ExtensionContext) {
		// register V-Slice debugger
		var debugProvider = Vscode.debug.registerDebugConfigurationProvider("funkin-run-game", {
			resolveDebugConfiguration: (folder, debugConfiguration, ?token) -> {
				var project_folder = folder?.uri.fsPath;

				if (project_folder == null) {
					Interaction.displayError(Language.RUNNING_FNF_WITHOUT_FOLDER);
				}
				var fnfCgf:FNFLaunchRequestArguments = cast debugConfiguration;
				var hasCwd = fnfCgf.cwd != null;

				var debugConfig = requestStaticConfiguration(project_folder, debugConfiguration);
				if (validateConfig(debugConfig))
					return debugConfig;
				else if (hasCwd)
					return null;
				else {
					var vscodeCfg = VsCodeConfig.instance;
					Interaction.requestDirectory(Language.SELECT_FNF_INSTANCE_TO_LAUNCH, vscodeCfg.GAME_PATH, inputPath -> {
						vscodeCfg.GAME_PATH = inputPath;
						Interaction.displayInformation(Language.PATH_UPDATED_TRY_AGAIN);
					}, () -> {
						Interaction.displayError(Language.OPERATION_CANCELLED);
					},true);
					return js.Lib.undefined;
				}
			}
		}, Initial);
		super(context,debugProvider);
	}
	/**
	 * Manually starts debugging of the V-Slice Engine.
	 * This method is rarely needed and preferably it should be ran with the "Run & Debug" configuration
	 */
	public function spawnFunkinGame() {
		if (Vscode.debug.activeDebugSession != null)
			return;
		var config = {
			type: "funkin-run-game",
			name: "Spawn Funkin instance",
			request: "launch"
		};
		var folder = Vscode.workspace?.workspaceFolders[0];

		if (folder == null) {
			Interaction.displayErrorAlert(Language.CANNOT_START_GAME_TITLE, Language.CANNOT_START_GAME_DETAIL);
			return;
		}

		Vscode.debug.startDebugging(folder, config).then((success) -> {
			if (!success) {
				Vscode.window.showErrorMessage(Language.FNF_FAILED_TO_FUNK, {modal: true});
			}
		});
	}

	/**
	 * Fills in the configuration data with the default values,
	 * but only where the user failed to do so.
	 * @param project_game_folder The path to the current project's directory 
	 * @param base The unsafe configuration provided by the user
	 * @return FNFLaunchRequestArguments The arguments to launch a debugging session with
	 */
	public function requestStaticConfiguration(project_game_folder:String, base:Dynamic):FNFLaunchRequestArguments {
		trace("AYO!!");
		if (base.isMobile == null)
			base.isMobile = false;
		if (base.execName == null){
			if(base.isMobile)
				base.execName = "me.funkin.fnf";
			else 
				base.execName = Sys.systemName() == "Windows" ? "Funkin.exe" : "Funkin";
		}
		if (base.cmd_prefix == null)
			base.cmd_prefix = "";
		if (base.args.isNull())
			base.args = [];
		if (base.trace.isNull())
			base.trace = VsCodeConfig.instance.DEBUG;
		if (base.attachDebugger == null)
			base.attachDebugger = true;		
		if (base.cwd.isNull())
			base.cwd = VsCodeConfig.instance.GAME_PATH;
		trace(base.preLaunchTask);
		if (base.preLaunchTask.isNull())
			base.preLaunchTask = "";

		var isCwdRelative = StringTools.startsWith(base.cwd, ".");
		if (isCwdRelative)
			base.cwd = Path.join([project_game_folder, base.cwd]);

		trace(base);
		return base;
	}

	private inline function validateConfig(cfg:FNFLaunchRequestArguments):Bool {
		if(cfg.isMobile){
			//TODO Should we add validation?
			return true;
		}
		else{
			var execDirPath = Path.join([FunkinPaths.getExecutableFolderPath(cfg.cwd), cfg.execName]);
			return FileSystem.exists(execDirPath);
		}
	}
}
