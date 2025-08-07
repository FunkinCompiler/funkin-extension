package mikolka.commands;

import mikolka.helpers.FileManager;
import mikolka.vscode.Interaction;

class ProjectTasks {

    var scaffold_path:String;
    public function new(scaffold_path:String) {
        this.scaffold_path = scaffold_path;
    }
    public function makeProject() {
        FileManager.getProjectPath(path ->{
            if(!FileManager.isFolderEmpty(path)){
                Interaction.displayErrorAlert("Folder not empty", 'Make sure that ${path} doesn\'t have any files in it.');
                return;
            }
            FileManager.copyRec(scaffold_path,path);
            Interaction.displayInformation("Done!");
        });
    }
}