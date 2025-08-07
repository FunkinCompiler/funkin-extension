package mikolka.vscode.providers;

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

class TaskRegistry {
	/**
	 * Constructs a CustomExecution task object. The callback will be executed when the task is run, at which point the
	 * extension should return the Pseudoterminal it will "run in". The task should wait to do further execution until
	 * {@link Pseudoterminal.open} is called. Task cancellation should be handled using
	 * {@link Pseudoterminal.close}. When the task is complete fire
	 * {@link Pseudoterminal.onDidClose}.
	 * @param callback The callback that will be called when the task is started by a user. Any ${} style variables that
	 * were in the task definition will be resolved and passed into the callback as `resolvedDefinition`.
	 */
	// This configures the code for the task
	static function getModCompileTask():CustomExecution {
		return new CustomExecution(resolvedDefinition -> new Promise((accept, reject) -> {
			var manifest:FunkTaskDefinition = cast resolvedDefinition;

			// Pulling the config in case the tasks missed those
			var vscodeConfig = new VsCodeConfig();
			if (manifest.modName == null || manifest.modName == "")
				manifest.modName = vscodeConfig.MOD_NAME;

			if (manifest.gamePath == null || manifest.gamePath == "")
				manifest.gamePath = vscodeConfig.GAME_PATH;

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

					CompileTask.CompileCurrentMod(game_cwd, manifest.modName, struct.writeLine);
				}));
			}
		}));
	}

	public function new(context:vscode.ExtensionContext) {
		var defaultTask = new Task({type: "funk"}, TaskScope.Workspace, "Compile current V-Slice mod", "Funk", getModCompileTask());

		context.subscriptions.push(Vscode.tasks.registerTaskProvider("funk", {
			resolveTask: TaskRegistry.resolveTask,
			provideTasks: token -> {
				return [defaultTask];
			}
		}));
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
