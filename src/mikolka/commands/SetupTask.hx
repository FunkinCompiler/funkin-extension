package mikolka.commands;

import vscode.TaskDefinition;
import vscode.Task;
import haxe.Exception;
import sys.io.File;
import sys.FileSystem;
import mikolka.vscode.Interaction;
import mikolka.helpers.LangStrings;
import mikolka.helpers.Process;

using StringTools;

typedef RepoLibrary = {
	name:String,
	clone_url:String,
	commit:String
}

class SetupTask extends Task {

	public function new() {
		
	}
	private static var localCwd:String = "";
	public static function task_setupEnvironment(template_url:String) {
        var force_lib_install:Bool = false;
		var postfix = " --never";
		Sys.println(LangStrings.MSG_SETUP_CHECKING_GIT);
		if (!Process.checkCommand("git -v")) {
			Interaction.displayError(LangStrings.SETUP_GIT_ERROR);
			return;
		}
		Sys.println(LangStrings.MSG_SETUP_CHECKING_HAXE);
		if (!Process.checkCommand("haxe --version")) {
			Interaction.displayError(LangStrings.SETUP_HAXE_ERROR);
			return;
		}

		Sys.println("[SETUP] Checking haxelib..");
		if (!Process.isPureHaxelib()) {
			Interaction.requestConfirmation(LangStrings.SETUP_HAXELIB_ERROR,() ->{

				Sys.println("Continuing!");
				installFunkinHaxelibs(template_url);
			},() ->{
				Interaction.displayError("Setup aborted!");

			});
		}
		else installFunkinHaxelibs(template_url);
	}

	static function installFunkinHaxelibs(template_url:String){

		Sys.println("[SETUP] Reading dependencies..");
		runSetupCommand("haxelib git thx.core  https://github.com/fponticelli/thx.core.git 2bf2b992e06159510f595554e6b952e47922f128 --never --skip-dependencies");
		runSetupCommand("haxelib git hmm  https://github.com/FunkinCrew/hmm.git --never --skip-dependencies");
		runSetupCommand("haxelib git grig.audio  https://gitlab.com/haxe-grig/grig.audio.git 57f5d47f2533fd0c3dcd025a86cb86c0dfa0b6d2 --never --skip-dependencies");
		runSetupCommand("haxelib git funkin https://github.com/FunkinCompiler/Funkin-lib.git 786e75e63a4529c99f5e0c4d943805610974c48d --always");
		var haxelib_repo = Process.resolveCommand("haxelib config").replace("\n","");

		// This installs into a local repo. We need to move them
		Sys.println("CWD: "+'${haxelib_repo}funkin/git/');
		localCwd = '${haxelib_repo}funkin/git/';
		runSetupCommand("haxelib run hmm reinstall");

		Sys.println("[SETUP] Moving dependencies..");
		for(dir in FileSystem.readDirectory('${haxelib_repo}funkin/git/.haxelib/')){
			
			try {

				FileSystem.rename(
					'${haxelib_repo}funkin/git/.haxelib/$dir',
					'${haxelib_repo}$dir'
					);
				}
				catch(x){
					trace('Move failed: ${haxelib_repo}funkin/git/.haxelib/$dir -> ${haxelib_repo}$dir/');
				}
		}
		var grig_dev_file = File.write('${haxelib_repo}.dev');
		grig_dev_file.writeString('${haxelib_repo}grig,audio/git/src');
		grig_dev_file.flush();
		grig_dev_file.close();

		Sys.println('[SETUP] Checking mod template..');
		if (!ProjectTasks.assertTemplateZip(template_url)) {
			Sys.println("Mod template is missing!");
		}

		Sys.println("[SETUP] Setup done!");
	}
    static function runSetupCommand(cmd:String):Bool {
        Sys.println("   > " + cmd);
        var code = Process.checkCommand(cmd,localCwd,"Setup step failed");

		return code;
    }
}
