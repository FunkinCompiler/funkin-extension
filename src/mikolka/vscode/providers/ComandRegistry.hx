package mikolka.vscode.providers;

import mikolka.vscode.definitions.DisposableProvider;
import vscode.Disposable;
import mikolka.config.VsCodeConfig;
import mikolka.helpers.Process;
import vscode.OutputChannel;
import mikolka.commands.*;

class CommandRegistry extends DisposableProvider {
	
	var commandOutput:OutputChannel;
    public function new(context:vscode.ExtensionContext) {
		commandOutput = Vscode.window.createOutputChannel("Funkin compiler");
        super(context,	
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

				
			}),
			makeCommand("new",context,() -> {
				new ProjectTasks(context.asAbsolutePath("./assets/scaffold")).makeProject();
			}),
			makeCommand("setHaxelib",context,() -> {
				var cfg = new VsCodeConfig();
				var result = Process.setHaxelibPath(cfg.HAXELIB_PATH);
				if(!result) Interaction.displayError("Failed to set haxelib path!");
				else Vscode.commands.executeCommand("haxe.restartLanguageServer");
			})
		);

    }
	override function dispose() {
		super.dispose();
		commandOutput.dispose();
	}

	    private function makeCommand(name:String,context:vscode.ExtensionContext,action:() -> Void):Disposable 
			return Vscode.commands.registerCommand("mikolka."+name, action);
    
}