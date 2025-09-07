package mikolka;

import mikolka.vscode.providers.StartupInit;
import mikolka.vscode.providers.TaskRegistry;
import mikolka.vscode.providers.DebuggerSetup;
import mikolka.vscode.providers.ComandRegistry;
import mikolka.vscode.providers.DiagnosticRegistry;

class Main {
    @:expose("activate")
    static function activate(context:vscode.ExtensionContext) {
		var registry = new CommandRegistry(context);
		var tasks = new TaskRegistry(context);
		var debugger = new DebuggerSetup(context);
		var diagnostics = new DiagnosticRegistry(context);
		var startup = new StartupInit(context);
		startup.runStartupChecks();
	}
}
