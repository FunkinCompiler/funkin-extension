package mikolka.vscode.providers.mode1;

import vscode.Disposable;
import mikolka.vscode.definitions.DisposableProvider;
import mikolka.config.VsCodeConfig;
import js.lib.Promise;
import js.lib.Promise.Thenable;
import haxe.io.Path;
import mikolka.commands.CompileTask;
import vscode.Pseudoterminal;
import mikolka.vscode.definitions.FunkTaskDefinition;
import vscode.ProviderResult;
import vscode.CancellationToken;
import vscode.TaskProvider;
import vscode.Task;
import vscode.TaskScope;
import vscode.CustomExecution;

/**
 * This class manages all tasks provided by this extension
 */
class TaskRegistry extends DisposableProvider {

	// This configures the code for the task
	/**
	 * Creates a CustomExecution object for the "Compile current V-Slice mod"task.
	 * 
	 * Such execution can be used to run it in the VsCode's task environment
	 * @param copyToGame Should this task also copy the compiled mod to V-Slice's "mods" folder
	 * @return CustomExecution
	 */
	static function getModCompileTask():CustomExecution {
		return new CustomExecution(resolvedDefinition -> new Promise((accept, reject) -> {
			var manifest:FunkTaskDefinition = cast resolvedDefinition;

			// Pulling the config in case the tasks missed those
			var vscodeConfig = new VsCodeConfig();
			if (manifest.modName == null || manifest.modName == "")
				manifest.modName = vscodeConfig.MOD_NAME;

			if (manifest.gamePath == null || manifest.gamePath == "")
				manifest.gamePath = vscodeConfig.GAME_PATH;

			if (manifest.copyToGame == null )
				manifest.copyToGame = true;

			trace(manifest);
			trace(vscodeConfig.MOD_NAME);

			if (Vscode.workspace.workspaceFolders == null || Vscode.workspace.workspaceFolders.length == 0) {
				reject("No folder seems to be opened! This is not supported!");
			} else {
				var full_project_path = Vscode.workspace.workspaceFolders[0].uri.fsPath;

				accept(OutputTerminal.makeTerminal(struct -> {
					trace("Getting cwd:");
					var isGamePathRelative = StringTools.startsWith(manifest.gamePath,".");

					var game_cwd = isGamePathRelative 
						?  Path.join([full_project_path, manifest.gamePath]) 
						:  Path.normalize(manifest.gamePath);
					trace(manifest.copyToGame);
					CompileTask.CompileCurrentMod(game_cwd, struct.writeLine, manifest.modName,manifest.copyToGame);
				}));
			}
		}));
	}

	public function new(context:vscode.ExtensionContext) {
		var defaultTask = new Task({type: "funk"}, TaskScope.Workspace, "Compile current V-Slice mod", "Funk", getModCompileTask());
		var exportTask = new Task(cast {type: "funk", copyToGame:false}, TaskScope.Workspace, "Export current V-Slice mod", "Funk", getModCompileTask());

		//Register task provider
		var disposeHook = Vscode.tasks.registerTaskProvider("funk", {
			resolveTask: TaskRegistry.resolveTask,
			provideTasks: token -> {
				return [defaultTask,exportTask];
			}
		});
		super(context,disposeHook);
	}

	/**
	 * Resolves a task that has no {@linkcode Task.execution execution} set. Tasks are
	 * often created from information found in the `tasks.json`-file. Such tasks miss
	 * the information on how to execute them and a task provider must fill in
	 * the missing information in the `resolveTask`-method. This method will not be
	 * called for tasks returned from the above `provideTasks` method (LIAR!!!) 
	 *
	 * A valid default implementation for the
	 * `resolveTask` method is to return `undefined`.
	 *
	 * Note that when filling in the properties of `task`, you _must_ be sure to
	 * use the exact same `TaskDefinition` and not create a new one. Other properties
	 * may be changed.
	 *
	 * @param task The task to resolve.
	 * @param token A cancellation token.
	 * @return The resolved task
	 */
	static function resolveTask(task:Task, token:CancellationToken):ProviderResult<Task> {
		trace("Resolving partial task");

		if (task.execution == null)
			task.execution = getModCompileTask();
		return task;
	}
}
