package mikolka.vscode.providers.commands;

import vscode.Uri;
import mikolka.install.backend.TaskChips;
import mikolka.install.chips.MiscEnvChecks;
import mikolka.install.files.ManifestParser;
import vscode.OutputChannel;
import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;
import haxe.Exception;
import mikolka.config.VsCodeConfig;
import mikolka.vscode.definitions.DisposableCommand;
import thx.semver.Version;

class SetupCommand extends DisposableCommand {
	var commandOutput:OutputChannel;
	var context:vscode.ExtensionContext;
	var fcpkg:ExternalStorageTools;

	public function new(context:vscode.ExtensionContext) {
		fcpkg = context.getGlobalStore();
		this.context = context;
		commandOutput = Vscode.window.createOutputChannel("Funkin compiler");
		super(context, makeCommand("setup", context, HaxeHelper.activate.bind(context,command_setup)));
	}

	private function writeLine(txt:String) {
		trace(txt);
		commandOutput.appendLine(txt);
	}
	private function showConsoleOutput(initMsg:String) {
		commandOutput.show();
		writeLine(initMsg);
	}
	private function command_setup() {
		HaxeHelper.checkVshaxeHaxelib( () -> {
			var taskResult = TaskChips.runChips([pickHaxelibRepo]);
			taskResult.then(onSetupDone, onSetupFail);
		},(reason) ->{
			onSetupFail(reason);
		});
		// var console = Out

	}

	function onSetupFail(reason:String) {
		commandOutput.show();
		Interaction.displayError(reason).then(_ -> {
			commandOutput.hide();
			commandOutput.clear();
		});
	}

	function onSetupDone(_:Dynamic) {
		Interaction.displayInformation(Language.FUNKIN_SETUP_COMPLETED_SUCCESSFULLY).then(_ -> {
			commandOutput.hide();
		});
	}

	function chip_done(resolve:Void->Void, deny:String->Void, ctx:TaskChips) {
		fcpkg.clearTempPath();
		writeLine("[SETUP] Setup done!");
		resolve();
	}

	function installFcpkg(ctx:TaskChips, path:String) {
		var haxelib_name = Path.withoutExtension(Path.withoutDirectory(path));
		var haxelib_path = Path.join([fcpkg.getHaxelibRootPath(), haxelib_name]);
		var environmentTesting = new MiscEnvChecks(writeLine);
		VsCodeConfig.instance.HAXELIB_PATH = haxelib_path;

		FileSystem.createDirectory(haxelib_path);
		Process.setHaxelibPath(haxelib_path);

		ctx.appendTask(environmentTesting.testEnvironment);
		ctx.appendTask((_resolve, _deny, _ctx) -> {
			try {
				ZipTools.extractZip(File.read(path), haxelib_path);
				var manifest = new ManifestParser(haxelib_path);
				//TODO Replace with proper version management once we implement more versions
				if(manifest.installJsonVersion <= Main.INSTALL_VERSION){
					var installTasks = manifest.buildTaskList(writeLine);
					if (VsCodeConfig.instance.DEBUG) {
						writeLine('[DEBUG] Built ${installTasks.length} install tasks.');
						writeLine('[DEBUG] Starting from stage ${manifest.installStage}');
					}
					_ctx.appendManyTasks(installTasks);
					_resolve();
				}
				else {
					_deny("Incompatible fcpkg format. Please update the extension!");
				}
			} catch (x:Exception) {
				_deny("Unpacking fcpkg zip failed! " + x.message);
			}
		});
		ctx.appendTask(chip_done);
	}

	function downloadFcpkg(remote_source:Uri, onComplete:(fcpkgPath:String) -> Void) {
		var name = Path.withoutExtension(Path.withoutDirectory(remote_source.path));
		var download_path = fcpkg.getTempPath();

		Process.runCurl(remote_source.toString(),'${name}.fcpkg', download_path, writeLine,
			onComplete.bind(Path.join([download_path, '${name}.fcpkg'])));
	}

	function pickHaxelibRepo(resolve:Void->Void, deny:String->Void, ctx:TaskChips) {
		trace("Request setup");
		ListPicker.pickFcpkgUri("Select fcpkg package to install", target -> {
			if (target == null)
				deny("No haxelib folder was set");
			else if (target.scheme == "file") {
				var path = target.fsPath;
				showConsoleOutput('Installing fcpkg from ${path}');
				if (!FileSystem.exists(path)) {
					deny("This fcpkg does not exist!");
				} else {
					installFcpkg(ctx, path);
					resolve();
				}
			} else {
				showConsoleOutput('Downloading fcpkg from ${target.toString()}');
				downloadFcpkg(target, fcpkgPath -> {
					if (!FileSystem.exists(fcpkgPath)) {
						deny("Could not download the package!");
					} else {
						writeLine("Downloaded. Installing...");
						installFcpkg(ctx, fcpkgPath);
						resolve();
					}
				});
			}
		});
	}

	override function dispose() {
		super.dispose();
		commandOutput.dispose();
	}
}
