package mikolka.vscode.providers.commands;

import mikolka.config.VsCodeConfig;
import haxe.io.Path;
import sys.FileSystem;
import mikolka.vscode.definitions.DisposableCommand;
import vscode.Uri;
import mikolka.install.backend.Cppia;

class CPPIACompile extends DisposableCommand {
	public function new(context:vscode.ExtensionContext) {
		super(context);
		addDisposable(makeCommand("cppia.compilesdk", context, command_compile));
	}

	function command_compile() {
		if(!FileSystem.exists(Path.join([VsCodeConfig.instance.HAXELIB_PATH, "export_classes.info"]))) {
            Cppia.compileExportClasses();
        }
        else{
            Interaction.displayInformation("CPPIA SDK is already compiled!");
        }
	}
}
