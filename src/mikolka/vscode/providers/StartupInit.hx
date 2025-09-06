package mikolka.vscode.providers;

import haxe.io.Path;
import mikolka.helpers.Process;
import mikolka.helpers.LangStrings;
import mikolka.config.VsCodeConfig;
using StringTools;

/**
 * This class manages the startup of the Funkin compiler
 */
class StartupInit {
    public function new(context:vscode.ExtensionContext) {

    }
    public function runStartupChecks() {
        var cfg = new VsCodeConfig();
        if(cfg.HAXELIB_PATH == null || cfg.HAXELIB_PATH == ""){
            // Haxelib not inited
            Vscode.window.showWarningMessage("Startup warning",{
                detail: LangStrings.STARTUP_SETUP_MISSING,
                modal: true
            },"Yes","No").then(s ->{
                if(s == "Yes") Vscode.commands.executeCommand("mikolka.setup");
            });
            return;
        }
        var haxelib_repo = Path.removeTrailingSlashes(Process.resolveCommand("haxelib config").replace("\n", ""));
        var user_repo = Path.removeTrailingSlashes(cfg.HAXELIB_PATH);
        if(haxelib_repo != user_repo){
             Vscode.window.showWarningMessage(LangStrings.STARTUP_SETUP_DIFFERENT_HAXELIB,"Yes","No").then(s ->{
                if(s == "Yes") {
                    Vscode.commands.executeCommand("mikolka.setHaxelib");
                };
            });
            return;
        }
        Vscode.window.showInformationMessage("Funkin Compiler is now running!");
        //
    }
}