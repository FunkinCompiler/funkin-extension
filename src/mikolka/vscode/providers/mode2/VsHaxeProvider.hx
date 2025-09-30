package mikolka.vscode.providers.mode2;

import sys.FileSystem;
import haxe.io.Path;
import sys.io.File;
import mikolka.vscode.definitions.DisposableProvider;
import vscode.Disposable;
using StringTools;

class VsHaxeProvider extends DisposableProvider {
    public var haxeApi:Vshaxe;
    public function new(context:vscode.ExtensionContext) {
        
        Vscode.extensions.getExtension("nadako.vshaxe").activate().then((x) ->{
            trace(Vscode.extensions.getExtension("nadako.vshaxe").extensionPath);
            onVshaxeActive(context);
        });
        //checkVshaxePatch();
        super(context);
    }

    private function onVshaxeActive(context:vscode.ExtensionContext) {
        haxeApi = Vscode.extensions.getExtension("nadako.vshaxe").exports;
        var cancelHook = haxeApi.registerDisplayArgumentsProvider("Funkin",{
            description: "Activates Autocompletion within compiled FNF Mods (Mode 2)",
            activate: provideArguments -> {
                var hxml = File.getContent(context.asAbsolutePath("assets/scaffold/build.hxml"));
                provideArguments(haxeApi.parseHxmlToArguments(hxml));
            },
            deactivate: () -> {}
        });
        addDisposable(cancelHook);
    }
    /**
        Checks and asks to apply a patch for the .hxc files.

        This also makes a backup in case anything goes wrong.
    **/
    private function checkVshaxePatch() {
        // 
        final jsPath = Path.join([Vscode.extensions.getExtension("nadako.vshaxe").extensionPath,"server/bin/"]);
        final jsBakPath = Path.join([jsPath,"server.js.bak"]);
        
        if(FileSystem.exists(jsBakPath)) return;
        Interaction.requestConfirmation(
            "Funkin Compiler Setup (mode 2)",
            "Looks like you don't have a patch applied to 'vshaxe language server' yet!\n"+
            "The program will now add support for .hxc files to it.\n\nDo you want to proceed?",
            () -> {
                final jsScriptPath = Path.join([jsPath,"server.js"]);
                // Make a backup
                File.copy(jsScriptPath,jsBakPath);

                var vshaxeJsServerCode = File.getContent(jsScriptPath);
                vshaxeJsServerCode = vshaxeJsServerCode.replace(
                    'function Lt(e){return e.endsWith(".hx")}',
                    'function Lt(e){return e.endsWith(".hx") || e.endsWith(".hxc")}');

                File.saveContent(jsScriptPath,vshaxeJsServerCode);
                Vscode.commands.executeCommand("workbench.action.reloadWindow");
            },
            () ->{}
            );
    }
}