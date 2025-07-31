package mikolka;

import mikolka.vscode.providers.TaskRegistry;
import mikolka.vscode.providers.DebuggerSetup;
import mikolka.vscode.providers.ComandRegistry;

class Main {
    @:expose("activate")
    static function activate(context:vscode.ExtensionContext) {
        Vscode.window.showInformationMessage("Funkin Compiler is now running!");
		var registry = new CommandRegistry(context);
		var tasks = new TaskRegistry(context);
		var debugger = new DebuggerSetup(context);
		
	}
}
