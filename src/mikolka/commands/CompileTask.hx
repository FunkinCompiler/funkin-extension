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
using StringTools;

typedef CompileTaskConfig = {
	var mod_assets:String;
	var hxc_source:String;
	var fnfc_assets:String;
	var export_mod_path:String;
	var writeLine:String->Void;
}
/**
 * Contains user-fronting "Compile" task
 * 
 * This task compiles the Funkin cCompiler's project into V-Slice runnable mod
 */
class CompileTask {
	
	/**
	 * Compiles currently opened project to a V-Slice mod
	 * @param game_cwd The path to the V-Slice's root dorectory
	 * @param writeLine An export mothod for writing logs
	 * @param mod_name A name of the mod in the tasting environment
	 * @param copyToGame Should the mod also be copied to the game (for testing)
	 */
	public static function CompileCurrentMod(game_cwd:String, writeLine:String->Void,mod_name:String = "workbench",copyToGame:Bool = true) {
		if (game_cwd == null) {
			Interaction.displayErrorAlert("Error compiling mod", "No workspace opened!");
			return;
		}
		FileManager.getProjectPath(project_path -> {
			var dirName = Path.directory(game_cwd);
			trace(dirName);
			trace("Got path: "+Std.string([game_cwd, "mods", mod_name]));
			var export_mod_path = dirName.endsWith(".app") 
				? Path.join([game_cwd,"Contents","Resources", "mods", mod_name])
				: Path.join([game_cwd, "mods", mod_name]);

			var projectConfig = new FunkCfg(project_path);
			compileMod({
				hxc_source: Path.join([project_path, projectConfig.MOD_HX_FOLDER]),
				mod_assets: Path.join([project_path, projectConfig.MOD_CONTENT_FOLDER]),
				fnfc_assets: Path.join([project_path, projectConfig.MOD_FNFC_FOLDER]),
				export_mod_path: Path.join([project_path, "export"]),
				writeLine: writeLine
			});
			if(copyToGame){
				writeLine("Copying to the V-Slice...");
				FileManager.copyRec(Path.join([project_path, "export"]),export_mod_path);
			}
		});
	}

	/**
	 * Compiles the Funkin Compiler's project
	 * @param cfg Configuration for the compilation
	 */
	static function compileMod(cfg:CompileTaskConfig) // baseGane_modDir, Mod_Directory
	{
		if (!FileManager.isManifestPresent(cfg.mod_assets)) {
			Interaction.displayErrorAlert("Error", 'No manifest found in ${cfg.mod_assets}!');
			return;
		}
		FileManager.deleteDirRecursively(cfg.export_mod_path);
		FileManager.copyRec(cfg.mod_assets, cfg.export_mod_path);
		var fnfc = new Fnfc(cfg.fnfc_assets, cfg.export_mod_path, cfg.writeLine);
		var hxc = new Hxc(cfg.hxc_source, cfg.export_mod_path, cfg.writeLine);
		fnfc.processDirectory();
		hxc.processDirectory();
	}

}
