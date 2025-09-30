package mikolka.commands;

import vscode.Uri;
import mikolka.helpers.FileManager;

class ProjectTasks {

    var scaffold_path:String;
    public function new(scaffold_path:String) {
        this.scaffold_path = scaffold_path;
    }
    public function makeProject() {
        var defaultDir = Vscode.workspace.workspaceFolders.length>0 ?  
            Vscode.workspace.workspaceFolders[0].uri.fsPath : "";
        Interaction.requestDirectory("Select a directory to create the project in",defaultDir,path ->{
            if(!FileManager.isFolderEmpty(path)){
                Interaction.displayErrorAlert("Folder not empty", 'Make sure that ${path} doesn\'t have any files in it.');
                return;
            }
            FileManager.copyRec(scaffold_path,path);
            Interaction.displayInformation("Done!");
            if(path != defaultDir) Vscode.commands.executeCommand("vscode.openFolder", Uri.file(path));
        },() -> {});
    }
}