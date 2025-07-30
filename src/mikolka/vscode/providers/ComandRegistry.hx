package mikolka.vscode.providers;

import mikolka.commands.*;

class CommandRegistry {
    private static function makeCommand(name:String,context:vscode.ExtensionContext,action:() -> Void) {
        context.subscriptions.push(
            Vscode.commands.registerCommand("mikolka."+name, action));
    }
    public static function registerCommands(context:vscode.ExtensionContext) {
        var cfg = Main.projectConfig;
        
		makeCommand("setup",context,() -> {
			//var console = Out
			OutputTerminal.makeTerminal(struct -> {
				var setup = new SetupTask(struct.writeLine);
				setup.task_setupEnvironment();
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
}