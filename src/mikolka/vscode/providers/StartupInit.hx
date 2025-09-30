package mikolka.vscode.providers;

import mikolka.vscode.definitions.DisposableProvider;
import haxe.io.Path;
import mikolka.helpers.Process;
import mikolka.helpers.LangStrings;
import mikolka.config.VsCodeConfig;
using StringTools;

/**
 * This class manages the startup of the Funkin compiler
 */
class StartupInit extends DisposableProvider {
    public function new(context:vscode.ExtensionContext) {
        super(context);
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
        if(Main.isMode2Active){
            Vscode.window.showInformationMessage("Change the extension of scripts from '.hxc' to '.hx' to access autocompletion capabilities!");
            Vscode.window.showInformationMessage("Funkin Compiler (mode 2) is running");
        } 
        else Vscode.window.showInformationMessage("Funkin Compiler is now running!");
        //
    }
}