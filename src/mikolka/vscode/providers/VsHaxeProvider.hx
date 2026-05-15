package mikolka.vscode.providers;

import sys.FileSystem;
import haxe.io.Path;
import sys.io.File;
import mikolka.vscode.definitions.DisposableProvider;
import vscode.Disposable;
using StringTools;

class VsHaxeProvider extends DisposableProvider {
    public var haxeApi:Vshaxe;
    private var haveIAskedAboutHxc:Bool = false;
    public function new(context:vscode.ExtensionContext) {
        
        Vscode.extensions.getExtension("nadako.vshaxe").activate().then((x) ->{
            trace(Vscode.extensions.getExtension("nadako.vshaxe").extensionPath);
            onVshaxeActive(context);
        });
        
        addDisposable(Vscode.window.onDidChangeActiveTextEditor(e ->{
            if(e.document.fileName.endsWith(".hxc") && !haveIAskedAboutHxc){
                haveIAskedAboutHxc = true;
                checkVshaxePatch();
            }
        }));
        super(context);
    }

    private function onVshaxeActive(context:vscode.ExtensionContext) {
        haxeApi = Vscode.extensions.getExtension("nadako.vshaxe").exports;
        var cancelHook = haxeApi.registerDisplayArgumentsProvider("Funkin",{
            description: "Activates Autocompletion using FNF source code",
            activate: provideArguments -> {
                var hxml = File.getContent(context.asAbsolutePath("assets/funkin-index.hxml"));
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
            "Funkin Compiler",
            "Looks like you don't have a patch applied to 'vshaxe language server' yet!\n"+
            "The program will now add support for .hxc files to it.\n\nDo you want to proceed?",
            () -> {
                final jsScriptPath = Path.join([jsPath,"server.js"]);
                // Make a backup
                File.copy(jsScriptPath,jsBakPath);

                var vshaxeJsServerCode = File.getContent(jsScriptPath);
                vshaxeJsServerCode = ~/function ([A-Z][a-z])\(e\){return e\.endsWith\("\.hx"\)/g
                    .replace(vshaxeJsServerCode,'function $1(e){return e.endsWith(".hx") || e.endsWith(".hxc")}');

                File.saveContent(jsScriptPath,vshaxeJsServerCode);
                Vscode.commands.executeCommand("workbench.action.reloadWindow");
            },
            () ->{}
            );
    }
}