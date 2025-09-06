package mikolka.vscode.definitions;

import vscode.TaskDefinition;

typedef FunkTaskDefinition = TaskDefinition & {
    var modName:String;
    var gamePath:String;
    var copyToGame:Bool;
}