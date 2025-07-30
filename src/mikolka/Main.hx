package mikolka;

import mikolka.vscode.providers.TaskRegistry;
import mikolka.vscode.*;
import mikolka.vscode.providers.DebuggerSetup;
import mikolka.vscode.providers.ComandRegistry;
import mikolka.config.FunkCfg;

class Main {
	public static var projectConfig:FunkCfg ;
    @:expose("activate")
    static function activate(context:vscode.ExtensionContext) {
        Vscode.window.showInformationMessage("Hello from Haxe!");
		context.subscriptions.push(Vscode.commands.registerCommand("hellohaxe.sayHello", function() {
			Vscode.window.showInformationMessage("Hello from Haxe!");
		}));
		CommandRegistry.registerCommands(context);
		TaskRegistry.registerTasks(context);
		DebuggerSetup.init(context);
		// context.subscriptions.push(Vscode.debug.registerDebugConfigurationProvider("funkin-game",{
		// 	provideDebugConfigurations: (folder, ?token) -> {
		// 		return DebugConfiguration
		// 	}
		// }));
		
	}
}
