package mikolka.install;

import haxe.io.Path;
import haxe.io.Input;
import sys.io.File;
import sys.FileSystem;
import mikolka.install.backend.TaskChips.ChipTask;
import mikolka.install.backend.TaskChips;
import mikolka.install.backend.HmmParser;

class FunkinLibrariesInstall {
	final DEV_LIBRARIES = ["grig,audio"];
	public function new(writeLine:String->Void, haxelib_repo:String, funkin_commit:String) {
		this.writeLine = writeLine;
		localCwd = haxelib_repo;
		this.funkin_commit = funkin_commit;
	}

	var writeLine:String->Void;
	var localCwd:String = null;
	var funkin_commit:String = null;

	// https://codeload.github.com/FunkinCrew/Funkin/zip/
	public function installFunkin(resolve:Void->Void, deny:String->Void, ctx:TaskChips) {
		installLibraryFromGithub("FunkinCrew/Funkin","668681250489b6a452ed20b915e51e4ba67a5073","funkin",() ->{
			FileSystem.rename(Path.join([localCwd,"funkin","git","source"]),Path.join([localCwd,"funkin","git"]));
			resolve();
		},deny);
	}

	public function installLibrariesFromHmm(haxelib_repo:String):ChipTask {
		return (_resolve:Void->Void, _deny:String->Void, ctx:TaskChips) -> {
			var hmm = new HmmParser(localCwd,writeLine);
			var libs = hmm.getLibraries();
			writeLine("[SETUP] Reading dependencies..");
			writeLine("CWD: " + localCwd);
			if(libs == null) _deny("Pulling library info failed!");
			else for(installLib in libs){
				ctx.appendTask((resolve, deny, ctx) -> {

					switch (installLib.type){
						case GITHUB:
							installLibraryFromGithub(installLib.source,installLib.versionTag,installLib.haxeLibraryName,resolve,deny);
						case HAXELIB:
							installLibraryFromHaxelib(installLib.haxeLibraryName,installLib.versionTag,resolve);
						default: 
							deny("Unknown library: "+installLib.haxeLibraryName);
					}
				});
			}
			_resolve();
		};
	}

	function installLibraryFromHaxelib(libraryName:String,version:String,resolve:Void->Void){
		runSetupCommand('haxelib install ${libraryName} ${version} --always --quiet --skip-dependencies', resolve);
	}
	function installLibraryFromGithub(repoName:String,commitHash:String,libraryName:String,resolve:Void->Void, deny:String->Void) {
		runSetupCommand('curl -o temp.zip -A "Mozilla/5.0 (X11; Linux x86_64; rv:146.0) Gecko/20100101 Firefox/146.0" "https://codeload.github.com/${repoName}/zip/${commitHash}"',() -> {
			ZipTools.extractZip(File.read(Path.join([localCwd,"temp.zip"])),Path.join([localCwd,libraryName]));
			FileSystem.deleteFile(Path.join([localCwd,"temp.zip"]));

			var fsRead = FileSystem.readDirectory(Path.join([localCwd,libraryName]));
			if(fsRead.length != 1){
				deny('${Path.join([localCwd,libraryName])} has more than one file/dir. Something went wrong downloading ${libraryName}');
			}
			else{
				var folderName = fsRead[0];
				FileSystem.rename(Path.join([localCwd,libraryName,folderName]),Path.join([localCwd,libraryName,"git"]));
				if(DEV_LIBRARIES.contains(libraryName)) 
					File.saveContent(Path.join([localCwd,libraryName,".dev"]), Path.join([localCwd,libraryName,'git/src']));
				else File.saveContent(Path.join([localCwd,libraryName,".current"]),"git");
				resolve();
			}
		});
	}
	function runSetupCommand(cmd:String, next:Void->Void) {
		writeLine("   > " + cmd);
		var cwd = localCwd ?? Sys.getCwd();
		Process.runCommand(cmd, cwd, writeLine, next);
	}
}
