package mikolka.commands;

import mikolka.install.FullReplaceTask;
import mikolka.install.CodePatcher;
import mikolka.install.FunkinLibrariesInstall;
import mikolka.install.backend.TaskChips;
import mikolka.install.EnvironmentChecks;
import mikolka.install.backend.TaskChips;
import mikolka.install.backend.TaskChips.ChipTask;
import mikolka.config.VsCodeConfig;
import js.lib.Promise;
import haxe.Exception;
import sys.io.File;
import sys.FileSystem;
import mikolka.helpers.LangStrings;
import mikolka.helpers.Process;

using StringTools;

typedef RepoLibrary = {
	name:String,
	clone_url:String,
	commit:String
}

class SetupTask {
	public function new(writeLine:String->Void, haxePatchesPath:String) {
		this.writeLine = writeLine;
		this.haxePatchesPath = haxePatchesPath;
	}

	var writeLine:String->Void;
	var haxePatchesPath:String;

	public function task_setupEnvironment():Promise<Any> {
		return TaskChips.runChips([pickHaxelibRepo]);
		// We do a method chain here
		// yes, I'm indeed stupid
	}

	function pickHaxelibRepo(resolve:Void->Void, deny:String->Void, ctx:TaskChips) {
		var cfg = new VsCodeConfig();
		trace("Request setup");
		Interaction.requestDirectory("Select a folder to download haxelibs into...", cfg.HAXELIB_PATH, path -> {
			cfg.HAXELIB_PATH = path;
			Process.setHaxelibPath(path);

			ctx.appendTask(testEnvironment);
			resolve();
		}, deny.bind("No haxelib folder was set"));
	}

	function testEnvironment(resolve:Void->Void, deny:String->Void, ctx:TaskChips) {
		var obj = new EnvironmentChecks(writeLine);
		ctx.appendManyTasks([obj.checkGit, obj.checkHaxe, obj.checkIfHaxelibIsPure]);
		ctx.appendTask(installFunkinHaxelibs);
		resolve();
	}

	function installFunkinHaxelibs(resolve:Void->Void, deny:String->Void, ctx:TaskChips) {
		var haxelib_repo = Process.resolveCommand("haxelib config").replace("\n", "");
		var obj = new FunkinLibrariesInstall(writeLine, haxelib_repo, "9908c8be32d154c3ab820315702bf60af80ac026");
		var regexp = new FullReplaceTask(haxePatchesPath, haxelib_repo);
		Interaction.requestConfirmation("DEBUG", "Do you want to skip lib install?", () -> {
			ctx.appendManyTasks([CodePatcher.patchFnfCode, regexp.task]);
			ctx.appendTask((__resolve, __deny, ctx) -> {
				writeLine("[SETUP] Setup done!");
				__resolve();
			});
			resolve();
		}, () -> {
			ctx.appendManyTasks([
				obj.installFunkin,
				obj.installLibrariesFromHmm(haxelib_repo),
				CodePatcher.patchFnfCode,
				regexp.task
			]);
			ctx.appendTask((__resolve, __deny, ctx) -> {
				writeLine("[SETUP] Setup done!");
				__resolve();
			});
			resolve();
		});
	}
}
