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

class DebuggerSetup {
	public function new(context:vscode.ExtensionContext) {
		context.subscriptions.push(Vscode.debug.registerDebugConfigurationProvider("run-game", {
			resolveDebugConfiguration: (folder, debugConfiguration, ?token) -> {
				var project_folder = folder?.uri.fsPath;
				if(project_folder == null){
					Interaction.displayError("Running FNF without a folder! This will likely fail!");
				}
				requestStaticConfiguration(project_folder,debugConfiguration);
			}
		}, Initial));

	}

	public function spawnFunkinGame() {
		if (Vscode.debug.activeDebugSession != null)
			return;
		var config = {
			type: "run-game",
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

	public function requestStaticConfiguration(project_game_folder:String,base:Dynamic):FNFLaunchRequestArguments {
		trace("AYO!!");
		if(base.execName == null) base.execName = Sys.systemName() == "Windows" ? "Funkin.exe" : "Funkin";
		if(base.cmd_prefix == null) base.cmd_prefix = "";
		if(base.cmd_prefix == null) base.cmd_prefix = "";
		if(base.cmd_prefix == null) base.cmd_prefix = "";
		if(base.args == null) base.args = [];
		if(base.trace == null) base.trace = true;
		if(base.cwd == null) base.cwd = new VsCodeConfig().GAME_PATH;
		trace(base.preLaunchTask);
		if(base.preLaunchTask == Lib.undefined) base.preLaunchTask = "Funk: Compile current V-Slice mod";
		base.cwd = Path.join([project_game_folder,base.cwd]);

		trace(base);
		return base;
	}
}
