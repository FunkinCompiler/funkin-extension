package mikolka.commands;

import js.lib.Promise;
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

class SetupTask {
	public function new(writeLine:String->Void) {
		this.writeLine = writeLine;
	}

	var writeLine:String->Void;
	private var localCwd:Null<String> = null;

	public function task_setupEnvironment():Promise<Any> {
		return new Promise((resolve, deny) -> {
			var force_lib_install:Bool = false;
			var postfix = " --never";

			writeLine(LangStrings.MSG_SETUP_CHECKING_GIT);
			if (!Process.checkCommand("git -v")) {
				deny(LangStrings.SETUP_GIT_ERROR);
			} else {
				writeLine(LangStrings.MSG_SETUP_CHECKING_HAXE);
				if (!Process.checkCommand("haxe --version")) {
					deny(LangStrings.SETUP_HAXE_ERROR);
				} else {
					writeLine("[SETUP] Checking haxelib..");
					if (!Process.isPureHaxelib()) {
						Interaction.requestConfirmation(LangStrings.SETUP_HAXELIB_ERROR_TITLE, LangStrings.SETUP_HAXELIB_ERROR, () -> {
							writeLine("Continuing!");
							installFunkinHaxelibs();
							resolve(null);
						}, () -> {
							deny("Funkin setup aborted!");
						});
					} else {
						installFunkinHaxelibs();
						resolve(null);
					}
				}
			}
		});
	}

	function installFunkinHaxelibs() {
		writeLine("[SETUP] Reading dependencies..");
		localCwd = null;
		runSetupCommand("haxelib git thx.core  https://github.com/fponticelli/thx.core.git 2bf2b992e06159510f595554e6b952e47922f128 --never --skip-dependencies");
		runSetupCommand("haxelib git hmm  https://github.com/FunkinCrew/hmm.git --never --skip-dependencies");
		runSetupCommand("haxelib git grig.audio https://github.com/FunkinCrew/grig.audio 8567c4dad34cfeaf2ff23fe12c3796f5db80685e --never --skip-dependencies");
		runSetupCommand("haxelib git funkin https://github.com/FunkinCompiler/Funkin-lib.git caeb00f5ed84405f06671ee4e9e3cdbb903008a6 --always");
		var haxelib_repo = Process.resolveCommand("haxelib config").replace("\n", "");

		// This installs into a local repo. We need to move them
		writeLine("CWD: " + '${haxelib_repo}funkin/git/');
		localCwd = '${haxelib_repo}funkin/git/';
		Process.runCommand("haxelib run hmm reinstall", localCwd, writeLine, () -> finaliseSetup(haxelib_repo));
	}

	function finaliseSetup(haxelib_repo:String) {
		writeLine("[SETUP] Moving dependencies..");
		for (dir in FileSystem.readDirectory('${haxelib_repo}funkin/git/.haxelib/')) {
			try {
				FileSystem.rename('${haxelib_repo}funkin/git/.haxelib/$dir', '${haxelib_repo}$dir');
			} catch (x) {
				writeLine('Move failed: ${haxelib_repo}funkin/git/.haxelib/$dir -> ${haxelib_repo}$dir/');
			}
		}
		var grig_dev_file = File.write('${haxelib_repo}.dev');
		grig_dev_file.writeString('${haxelib_repo}grig,audio/git/src');
		grig_dev_file.flush();
		grig_dev_file.close();

		writeLine('[SETUP] Checking mod template..');

		writeLine("[SETUP] Setup done!");
	}

	function runSetupCommand(cmd:String):Bool {
		writeLine("   > " + cmd);
		var cwd = localCwd ?? Sys.getCwd();
		var code = Process.checkCommand(cmd, cwd, "Funkin setup step failed");

		return code;
	}
}
