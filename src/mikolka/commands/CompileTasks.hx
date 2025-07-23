package mikolka.commands;

import mikolka.helpers.LangStrings;
import mikolka.programs.Hxc;
import mikolka.programs.Fnfc;
import mikolka.helpers.Process;
import mikolka.vscode.Interaction;
import haxe.io.Path;
import sys.FileSystem;
import mikolka.helpers.ZipTools;
import mikolka.helpers.FileManager;
import sys.io.File;

class CompileTasks {
	public static function Task_ExportGame(mod_assets:String, hxc_source:String, fnfc_assets:String, export_mod_path:String) {
		if (!FileManager.isManifestPresent(mod_assets)) {
			Interaction.displayError(LangStrings.MSG_EXPORT_META_MISSING);
			return;
		}
		var manifestPath = '$mod_assets/_polymod_meta.json';
		var poly_json = File.getContent(manifestPath);

		var varGetter:EReg = ~/"mod_version": *"([0-9.]+)" */i;
		if (!varGetter.match(poly_json)) {
			Interaction.displayError(LangStrings.MSG_EXPORT_META_NO_VERSION);
			return;
		}

		Interaction.requestInput(LangStrings.MSG_EXPORT_ZIP_NAME, (userModName) -> {
			var currentModVersion = varGetter.matched(1);
			Vscode.window.showInputBox({
				title: LangStrings.MSG_EXPORT_MOD_VERSION,
				prompt: "replace this!!!",
				placeHolder: "1.0.0",
				value: currentModVersion,
				validateInput: (input:String) -> {
					var validator:EReg = ~/[0-9.]+/i;
					if (!validator.match(input) && input != "") {
						return "Invalid version string. Use Semacic versioning here!";
					}
					return null;
				},
			}).then((userModVersion:String) -> {
				if (userModVersion != "") {
					var new_poly = varGetter.replace(poly_json, '"mod_version": "${userModVersion}"');
					File.saveContent(manifestPath, new_poly);
					trace('Updated you mod\'s version to ${userModVersion}');
				}

				Task_CompileGame(mod_assets, hxc_source, fnfc_assets, export_mod_path);

				// create the output file
				var out = sys.io.File.write('${userModName}.zip', true);
				ZipTools.makeZipArchive(export_mod_path, out);
			}, (out) -> {
				Interaction.displayError("Action canceled!");
			});
		});
	}

	public static function Task_CompileGame(mod_assets:String, hxc_source:String, fnfc_assets:String, export_mod_path:String) // baseGane_modDir, Mod_Directory
	{
		if (!FileManager.isManifestPresent(mod_assets))
			return;
		FileManager.deleteDirRecursively(export_mod_path);
		copyTemplate(mod_assets, export_mod_path);
		var fnfc = new Fnfc(fnfc_assets, export_mod_path);
		var hxc = new Hxc(hxc_source, export_mod_path);
		fnfc.processDirectory();
		hxc.processDirectory();
	}

	public static function Task_RunGame(game_path:String) {
		var project_game_folder = FileManager.getProjectPath(game_path) ?? "";
		var linux_bin = FileManager.doesTargetExist(Path.join([game_path, "Funkin"]));
		var windows_bin = FileManager.doesTargetExist(Path.join([game_path, "Funkin.exe"]));
		var mac_bin = FileManager.doesTargetExist(Path.join([game_path, "Funkin.app"])); // not supported
		if (windows_bin) {
			if (Sys.systemName() == "Windows")
				Process.spawnFunkinGame(project_game_folder, "Funkin.exe");
			else {
				trace("[INFO] Windows build on non-windows machine. Attempting to run using wine...");
				Process.spawnFunkinGame(project_game_folder, "Funkin.exe", "wine ");
			}
		} else if (linux_bin) {
			if (Sys.systemName() == "Linux")
				Process.spawnFunkinGame(project_game_folder, "Funkin");
			else
				Interaction.displayError('Incompatible FNF version. Replace it with the windows one.');
		} else if (mac_bin && Sys.systemName() == "Mac")
			Interaction.displayError("I personally don't know how to run the game natively on your platform\n"
				+ "You might try to install wine and use Windows build instead");
		else
			Interaction.displayError('No FNF binary found. Make sure that there\'s copy of FNF in $project_game_folder directory.');
	}

	private static function copyTemplate(mod_assets:String, export_mod_path:String) {
		FileSystem.createDirectory(mod_assets);
		FileManager.scanDirectory(mod_assets, s -> {
			FileSystem.createDirectory(Path.join([export_mod_path, Path.directory(s)]));
			File.copy('$mod_assets/$s', Path.join([export_mod_path, s]));
		}, s -> {});
	}
}
