package mikolka.vscode.providers;

import vscode.OutputChannel;
import mikolka.commands.*;

class CommandRegistry {
	
	var commandOutput:OutputChannel;
    public function new(context:vscode.ExtensionContext) {
		commandOutput = Vscode.window.createOutputChannel("Funkin compiler");
        
		makeCommand("setup",context,() -> {
			//var console = Out
			var setup = new SetupTask((txt) -> commandOutput.appendLine(txt));
			commandOutput.show();

			setup.task_setupEnvironment().then((_) ->{
				Interaction.displayInformation("Funkin setup completed successfully!").then(_ ->{
					commandOutput.hide();
				});
			},(reason) ->{
				commandOutput.show();
				Interaction.displayError(reason).then(_ ->{
					commandOutput.hide();
					commandOutput.clear();
				});
			});

			
		});
		makeCommand("new",context,() -> {
			new ProjectTasks(context.asAbsolutePath("./assets/scaffold")).makeProject();
		});

		//TODO Zip exports are a bit wonky right now!
		// makeCommand("export",context,() -> {
		// 	CompileTask.CompileCurrentMod(cfg.MOD_CONTENT_FOLDER, cfg.MOD_HX_FOLDER, cfg.MOD_FNFC_FOLDER, cfg.GAME_PATH+"/mods/"+cfg.GAME_MOD_NAME);
		// 	trace("Done!");
		// });
    }

	    private function makeCommand(name:String,context:vscode.ExtensionContext,action:() -> Void) {
        context.subscriptions.push(
            Vscode.commands.registerCommand("mikolka."+name, action));
    }
}