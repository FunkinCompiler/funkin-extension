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
			SetupTask.task_setupEnvironment(cfg.TEMPLATE_REMOTE_SRC);
		});
		makeCommand("new",context,() -> {
			ProjectTasks.task_setupProject(cfg.TEMPLATE_REMOTE_SRC);
		});
		makeCommand("just-run",context,() -> {
			CompileTasks.Task_RunGame();
		});
		makeCommand("just-compile",context,() -> {
			CompileTasks.Task_CompileGame(cfg.MOD_CONTENT_FOLDER, cfg.MOD_HX_FOLDER, cfg.MOD_FNFC_FOLDER, cfg.GAME_PATH+"/mods/"+cfg.GAME_MOD_NAME);
			trace("Done!");
		});
		makeCommand("run",context,() -> {
			CompileTasks.Task_CompileGame(cfg.MOD_CONTENT_FOLDER, cfg.MOD_HX_FOLDER, cfg.MOD_FNFC_FOLDER, cfg.GAME_PATH+"/mods/"+cfg.GAME_MOD_NAME);
			CompileTasks.Task_RunGame();
		});
		makeCommand("export",context,() -> {
			CompileTasks.Task_ExportGame(cfg.MOD_CONTENT_FOLDER, cfg.MOD_HX_FOLDER, cfg.MOD_FNFC_FOLDER, cfg.GAME_PATH+"/mods/"+cfg.GAME_MOD_NAME);
			trace("Done!");
		});
    }
}