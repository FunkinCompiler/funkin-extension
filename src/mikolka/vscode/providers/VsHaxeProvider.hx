package mikolka.vscode.providers;

import vscode.ProgressLocation;
import mikolka.config.MetadataParser;
import mikolka.config.VsCodeConfig;
import sys.FileSystem;
import haxe.io.Path;
import sys.io.File;
import mikolka.vscode.definitions.DisposableProvider;

using StringTools;

class VsHaxeProvider extends DisposableProvider {
	public var haxeApi:Vshaxe;

	private var haveIAskedAboutHxc:Bool = false;

	public function new(context:vscode.ExtensionContext) {
		
		super(context, Vscode.window.onDidChangeActiveTextEditor(e -> {
			if (e.document.fileName.endsWith(".hxc") && !haveIAskedAboutHxc) {
				haveIAskedAboutHxc = true;
				checkVshaxePatch();
			}
		}));
		HaxeHelper.activate(context,onVshaxeActive.bind(context));
	}

	private function onVshaxeActive(context:vscode.ExtensionContext) {
		haxeApi = Vscode.extensions.getExtension("nadako.vshaxe").exports;

		addDisposable(haxeApi.registerDisplayArgumentsProvider("Funkin", {
			description: "Activates Autocompletion using FNF source code",
			activate: provideArguments -> {
				var current_manifest = MetadataParser.readActiveMetadata();
				var hxml_path = current_manifest.hxmlFile != null ? Path.join([VsCodeConfig.instance.HAXELIB_PATH, current_manifest.hxmlFile]) : context.asAbsolutePath("assets/funkin-index.hxml");
				if (VsCodeConfig.instance.DEBUG)
					trace(hxml_path);
				var hxml = File.getContent(hxml_path);
				
				provideArguments(haxeApi.parseHxmlToArguments(hxml)
					.filterInto(s -> !s.contains("--macro") && !s.startsWith("include"))
				);
			},
			deactivate: () -> {}
		}));
		addDisposable(haxeApi.registerHaxeInstallationProvider("Funkin IDE Haxe", {
			activate: provideInstallation -> {
				HaxeHelper.checkVshaxeHaxelib(() -> {
					provideInstallation({
						haxeExecutable: HaxeHelper.getHaxeExecutable(),
						standardLibraryPath: HaxeHelper.getHaxeStd(),
						haxelibExecutable: HaxeHelper.getHaxelibExecutable()
					});
					checkCurrentHaxelib();
				}, error -> {
					Interaction.displayError(error);
					provideInstallation({});
				});
			},
			deactivate: () -> {}
		}));
	}

	private function checkCurrentHaxelib() {
		var haxelib_repo = Path.removeTrailingSlashes(Process.resolveCommand(
			'${HaxeHelper.getHaxeExecutable().shellPath()} config').replace("\n", ""));
		var user_repo = Path.removeTrailingSlashes(VsCodeConfig.instance.HAXELIB_PATH);

		if (haxelib_repo != user_repo) {
			Vscode.window.showWarningMessage(Language.STARTUP_SETUP_DIFFERENT_HAXELIB, "Yes", "No").then(s -> {
				if (s == "Yes") {
					Vscode.commands.executeCommand("mikolka.setHaxelib");
				};
			});
			return;
		}
	}

	/**
		Checks and asks to apply a patch for the .hxc files.
		This also makes a backup in case anything goes wrong.
	**/
	private function checkVshaxePatch() {
		final jsPath = Path.join([Vscode.extensions.getExtension("nadako.vshaxe").extensionPath, "server/bin/"]);
		final jsBakPath = Path.join([jsPath, "server.js.bak"]);

		if (FileSystem.exists(jsBakPath))
			return;
		Interaction.requestConfirmation(Language.VSHAXE_PATCH_PROMPT_TITLE,
				Language.VSHAXE_PATCH_PROMPT,
			() -> {
				final jsScriptPath = Path.join([jsPath, "server.js"]);
				// Make a backup
				File.copy(jsScriptPath, jsBakPath);

				var vshaxeJsServerCode = File.getContent(jsScriptPath);
				vshaxeJsServerCode = ~/function ([A-Z][a-z])\(e\){return e\.endsWith\("\.hx"\)}/g.replace(vshaxeJsServerCode,
					'function $1(e){return e.endsWith(".hx") || e.endsWith(".hxc")}');

				File.saveContent(jsScriptPath, vshaxeJsServerCode);
				Vscode.commands.executeCommand("workbench.action.reloadWindow");
			}, () -> {});
	}
}
