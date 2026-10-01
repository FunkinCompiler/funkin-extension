package mikolka.vscode.definitions.tasks;

import vscode.TaskDefinition;

typedef CppiaTaskDefinitions = TaskDefinition & {
	sourcePath:String,
	cppiaOutFile:String,
	classesToCompile:Array<String>
}