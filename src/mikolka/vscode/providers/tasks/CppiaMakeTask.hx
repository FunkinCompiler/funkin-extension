package mikolka.vscode.providers.tasks;

import sys.FileSystem;
import mikolka.install.backend.Cppia;
import mikolka.install.backend.Cppia.CppiaMake;
import mikolka.vscode.definitions.tasks.CppiaTaskDefinitions;
import js.Lib;
import mikolka.vscode.definitions.DisposableProvider;
import mikolka.config.VsCodeConfig;
import js.lib.Promise;
import haxe.io.Path;
import vscode.ProviderResult;
import vscode.CancellationToken;
import vscode.Task;
import vscode.TaskScope;
import vscode.CustomExecution;

/**
 * This class manages all tasks provided by this extension
 */
class CppiaMakeTask extends DisposableProvider {
	// This configures the code for the task
	static var tools:ExternalStorageTools;
	/**
	 * Creates a CustomExecution object for the "Compile current V-Slice mod"task.
	 * 
	 * Such execution can be used to run it in the VsCode's task environment
	 * @param copyToGame Should this task also copy the compiled mod to V-Slice's "mods" folder
	 * @return CustomExecution
	 */
	static function getTask():CustomExecution {
		return new CustomExecution(resolvedDefinition -> new Promise((accept, reject) -> {
			var manifest:CppiaTaskDefinitions = cast resolvedDefinition;
			if (Vscode.workspace.workspaceFolders == null || Vscode.workspace.workspaceFolders.length == 0) {
				reject("No folder seems to be opened! This is not supported!");
			} else {
				var full_project_path = Vscode.workspace.workspaceFolders[0].uri.fsPath;
				var compileConfig:CppiaMake = {
					sourcePath: Path.join([full_project_path,manifest.sourcePath]),
					classesToCompile: manifest.classesToCompile,
					cppiaOutFile: Path.join([full_project_path,manifest.cppiaOutFile])
				};

				// Pulling the config in case the tasks missed those
				var vscodeConfig = VsCodeConfig.instance;

				if (compileConfig.classesToCompile.isNull())
					compileConfig.classesToCompile = Cppia.buildClassNames(compileConfig.sourcePath);
				if(!FileSystem.exists(Path.join([VsCodeConfig.instance.HAXELIB_PATH, "export_classes.info"]))) 
					Cppia.compileExportClasses();

				var hxml_path = Cppia.makeCppiaHxml(tools,compileConfig);
				if(hxml_path == null){
					reject(Language.CPPIA_NOT_SUPPORTED);
					return;
				}
				accept(OutputTerminal.makeTerminal(struct -> {
					var out = Process.spawnSyncProcess(HaxeHelper.getHaxeExecutable(),
						[hxml_path.shellPath()]);
						struct.writeLine(out);
				}));
			}
		}));
	}

	public function new(context:vscode.ExtensionContext) {
		// Register task provider
		tools = context.getGlobalStore();
		var disposeHook = Vscode.tasks.registerTaskProvider("funk-cppia-make", {
			resolveTask: CppiaMakeTask.resolveTask,
			provideTasks: token -> {
				return [];
			}
		});
		super(context, disposeHook);
	}

	static function resolveTask(task:Task, token:CancellationToken):ProviderResult<Task> {
		trace("Resolving partial task");
		if (task.execution.isNull()) {
			var completeTask = new Task(task.definition, TaskScope.Workspace, "Compile Funkin CPPIA script", "Funk Cppia", getTask(), null);
			return completeTask;
		}
		return task;
	}
}
