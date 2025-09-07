package mikolka.commands;

import mikolka.config.VsCodeConfig;
import js.lib.Promise;
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
		return new Promise(pickHaxelibRepo);
		// We do a method chain here
		// yes, I'm indeed stupid
	}

	function pickHaxelibRepo(resolve:Any->Void, deny:String->Void) {
		final options = {
			placeHolder: "Select a folder to download haxelibs into...",

		}
		Vscode.window.showOpenDialog({
					canSelectFolders: true,
					canSelectFiles: false
				}).then(folders -> {
					if (folders != null && folders.length > 0) {
						var path = folders[0].fsPath;

						new VsCodeConfig().HAXELIB_PATH = path;
						Process.setHaxelibPath(path);
						testEnvironment(resolve,deny);
					}
					else deny("No haxelib folder was set");
				});
	}

	function testEnvironment(resolve:Any->Void, deny:String->Void) {
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
						installFunkinHaxelibs(resolve);
					}, () -> {
						deny("Funkin setup aborted!");
					});
				} else {
					installFunkinHaxelibs(resolve);
				}
			}
		}
	}

	function installFunkinHaxelibs(resolve:Any->Void) {
		var haxelib_repo = Process.resolveCommand("haxelib config").replace("\n", "");
		localCwd = null;
		writeLine("[SETUP] Reading dependencies..");

		// I love this line <3
		installThxCore(installGrig.bind(installHmm.bind(installFunkin.bind(() -> {
			// This installs into a local repo. We need to move them
			writeLine("CWD: " + '${haxelib_repo}funkin/git/');
			localCwd = '${haxelib_repo}funkin/git/';
			Process.runCommand("haxelib run hmm reinstall", localCwd, writeLine, () -> finaliseSetup(haxelib_repo, resolve));
		}))));
	}

	function installThxCore(next:Void->Void) {
		runSetupCommand("haxelib git thx.core  https://github.com/fponticelli/thx.core.git 2bf2b992e06159510f595554e6b952e47922f128 --never --skip-dependencies",
			next);
	}

	function installHmm(next:Void->Void) {
		runSetupCommand("haxelib git hmm https://github.com/FunkinCrew/hmm.git --never --skip-dependencies", next);
	}

	function installGrig(next:Void->Void) {
		runSetupCommand("haxelib git grig.audio https://github.com/FunkinCrew/grig.audio 8567c4dad34cfeaf2ff23fe12c3796f5db80685e --never",
			next);
	}

	function installFunkin(next:Void->Void) {
		runSetupCommand("haxelib git funkin https://github.com/FunkinCompiler/Funkin-lib.git c18d10026ed95381af10129c7132eb271db54a6e --always", next);
	}

	function finaliseSetup(haxelib_repo:String, resolve:Any->Void) {
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
		resolve(null);
	}

	function runSetupCommand(cmd:String, next:Void->Void) {
		writeLine("   > " + cmd);
		var cwd = localCwd ?? Sys.getCwd();
		Process.runCommand(cmd, cwd, writeLine, next);
	}
}
