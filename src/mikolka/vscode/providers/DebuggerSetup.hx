package mikolka.vscode.providers;

import js.Lib;
import mikolka.config.VsCodeConfig;
import mikolka.helpers.FileManager;
import haxe.io.Path;
import vscode.debugProtocol.DebugProtocol.LaunchRequestArguments;
import vscode.DebugConfiguration;

typedef FNFLaunchRequestArguments = DebugConfiguration & {
	var cwd:String;
	var cmd_prefix:String;
	var execName:String;
	var args:Array<String>;
	// final stopOnEntry:Bool;
	// final haxeExecutable:{
	// 	final executable:String;
	// 	final env:DynamicAccess<String>;
	// };
	// final mergeScopes:Bool;
	// final showGeneratedVariables:Bool;
	var trace:Bool; // if set to true sends trace messages as DebugSession.OutputEvents
}

/**
 * Class responsible for configuring debugger for Friday Night Funkin'.
 * This lets us capture logs and control it's process.
 */
class DebuggerSetup { //game_cwd:String, mod_name:String,
	public function new(context:vscode.ExtensionContext) {

		//register V-Slice debugger
		context.subscriptions.push(Vscode.debug.registerDebugConfigurationProvider("funkin-run-game", {
			resolveDebugConfiguration: (folder, debugConfiguration, ?token) -> {
				var project_folder = folder?.uri.fsPath;
				if(project_folder == null){
					Interaction.displayError("Running FNF without a folder! This will likely fail!");
				}
				requestStaticConfiguration(project_folder,debugConfiguration);
			}
		}, Initial));

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
		if(folder == null){
			Interaction.displayErrorAlert("Cannot start the game","You need to open a folder before starting it!");
			return;
		}
		Vscode.debug.startDebugging(folder, config).then((success) -> {
			if (!success) {
				Vscode.window.showErrorMessage("Funkin failed to funk!", {modal: true});
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
	public function requestStaticConfiguration(project_game_folder:String,base:Dynamic):FNFLaunchRequestArguments {
		trace("AYO!!");
		if(base.execName == null) base.execName = Sys.systemName() == "Windows" ? "Funkin.exe" : "Funkin";
		if(base.cmd_prefix == null) base.cmd_prefix = "";
		if(base.args == null) base.args = [];
		if(base.trace == null) base.trace = true;
		if(base.attachDebugger == null) base.attachDebugger = true;
		if(base.cwd == null) base.cwd = new VsCodeConfig().GAME_PATH;
		trace(base.preLaunchTask);
		if(base.preLaunchTask == Lib.undefined) base.preLaunchTask = "Funk: Compile current V-Slice mod";

		var isCwdRelative = StringTools.startsWith(base.cwd,".");
		if(isCwdRelative) base.cwd = Path.join([project_game_folder,base.cwd]);

		trace(base);
		return base;
	}
}
