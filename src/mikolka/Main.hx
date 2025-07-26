package mikolka;

import mikolka.vscode.*;
import mikolka.vscode.providers.ComandRegistry;
import mikolka.config.FunkCfg;

class Main {
	public static var projectConfig:FunkCfg ;
    @:expose("activate")
    static function activate(context:vscode.ExtensionContext) {
        Vscode.window.showInformationMessage("Hello from Haxe!");
		projectConfig = new FunkCfg();
		context.subscriptions.push(Vscode.commands.registerCommand("hellohaxe.sayHello", function() {
			Vscode.window.showInformationMessage("Hello from Haxe!");
		}));
		CommandRegistry.registerCommands(context);
		DebuggerSetup.init(context);
		// context.subscriptions.push(Vscode.debug.registerDebugConfigurationProvider("funkin-game",{
		// 	provideDebugConfigurations: (folder, ?token) -> {
		// 		return DebugConfiguration
		// 	}
		// }));
		
	}
}
