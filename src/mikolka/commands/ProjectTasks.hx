package mikolka.commands;

import mikolka.helpers.FileManager;
import mikolka.vscode.Interaction;
import mikolka.helpers.LangStrings;
import mikolka.config.FunkCfg;
import mikolka.helpers.ZipTools;

import haxe.io.Path;
import sys.io.File;

class ProjectTasks {
    private final FUNK_CFG = 
    "\n"+
    "\n"+
    "";
    var scaffold_path:String;
    public function new(scaffold_path:String) {
        this.scaffold_path = scaffold_path;
    }
    public function makeProject() {
        FileManager.getProjectPath(path ->{
            FileManager.copyRec(scaffold_path,path);
            File.saveContent(Path.join([path,"funk.cfg"]),FUNK_CFG);
            Interaction.showPressToContinue("Done!");
        });
    }
}