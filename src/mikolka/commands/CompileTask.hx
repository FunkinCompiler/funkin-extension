package mikolka.commands;

import mikolka.config.FunkCfg;
import mikolka.vscode.providers.DebuggerSetup;
import mikolka.helpers.LangStrings;
import mikolka.programs.Hxc;
import mikolka.programs.Fnfc;
import mikolka.helpers.Process;
import mikolka.vscode.Interaction;
import mikolka.helpers.ZipTools;
import mikolka.helpers.FileManager;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

typedef CompileTaskConfig = {
	var mod_assets:String;
	var hxc_source:String;
	var fnfc_assets:String;
	var export_mod_path:String;
	var writeLine:String->Void;
}

class CompileTask {
	// Overlay to pre-fill some values (because it's cleaner)
	public static function CompileCurrentMod(game_cwd:String, mod_name:String, writeLine:String->Void) {
		if (game_cwd == null) {
			Interaction.displayErrorAlert("Error compiling mod", "No workspace opened!");
			return;
		}
		FileManager.getProjectPath(project_path -> {
			trace("Got path: "+Std.string([game_cwd, "mods", mod_name]));
			var export_mod_path = Path.join([game_cwd, "mods", mod_name]);

			var projectConfig = new FunkCfg(project_path);
			Task_CompileGame({
				hxc_source: Path.join([project_path, projectConfig.MOD_HX_FOLDER]),
				mod_assets: Path.join([project_path, projectConfig.MOD_CONTENT_FOLDER]),
				fnfc_assets: Path.join([project_path, projectConfig.MOD_FNFC_FOLDER]),
				export_mod_path: export_mod_path,
				writeLine: writeLine
			});
		});
	}

	static function Task_CompileGame(cfg:CompileTaskConfig) // baseGane_modDir, Mod_Directory
	{
		if (!FileManager.isManifestPresent(cfg.mod_assets)) {
			Interaction.displayErrorAlert("Error", 'No manifest found in ${cfg.mod_assets}!');
			return;
		}
		FileManager.deleteDirRecursively(cfg.export_mod_path);
		copyTemplate(cfg.mod_assets, cfg.export_mod_path);
		var fnfc = new Fnfc(cfg.fnfc_assets, cfg.export_mod_path, cfg.writeLine);
		var hxc = new Hxc(cfg.hxc_source, cfg.export_mod_path, cfg.writeLine);
		fnfc.processDirectory();
		hxc.processDirectory();
	}

	private static function copyTemplate(mod_assets:String, export_mod_path:String) {
		FileSystem.createDirectory(mod_assets);
		FileManager.scanDirectory(mod_assets, s -> {
			FileSystem.createDirectory(Path.join([export_mod_path, Path.directory(s)]));
			File.copy('$mod_assets/$s', Path.join([export_mod_path, s]));
		}, s -> {});
	}
}
