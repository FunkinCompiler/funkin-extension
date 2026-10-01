package mikolka.vscode.providers.commands;

import haxe.Exception;
import mikolka.vscode.definitions.DisposableCommand;
import mikolka.config.VsCodeConfig;
import mikolka.config.MetadataParser;
import mikolka.vscode.ui.ListPicker.ListItem;
import haxe.io.Path;

using StringTools;

class SetHaxelibCommand extends DisposableCommand {
	var fcpkg:ExternalStorageTools;
	var ctx:vscode.ExtensionContext;
	var cfg:VsCodeConfig;

	public function new(context:vscode.ExtensionContext) {
		super(context);
		fcpkg = context.getGlobalStore();
		ctx = context;
		cfg = VsCodeConfig.instance;
		addDisposable(makeCommand("setHaxelib", context, command_setHaxelib));
	}

	function command_setHaxelib() {
		var folder_list = fcpkg.getInstalledHaxelibs();
		if (folder_list.length == 0)
			Interaction.displayError(Language.NO_FCPKG_PACKAGE_INSTALLED);
		else {
			var base_list:Array<ListItem> = makeHaxelibList(folder_list);
			if (cfg.HAXELIB_PATH != "")
				base_list.insert(0, {
					label: Language.USE_PREVIOUS,
					id: "last",
					onSelect: setConfigHaxelib,
					detail: cfg.HAXELIB_PATH.replace(ctx.globalStorageUri.fsPath,"~")
				});
			if (cfg.DEBUG)
				trace(base_list);
			ListPicker.pickHaxelibFolder(base_list, setHaxelibFolder, setHaxelibPath);
		}
	}

	function makeHaxelibList(folders:Array<String>):Array<ListItem> {
		return folders.mapInto(folder_name -> {
			var full_path = Path.join([fcpkg.getHaxelibRootPath(), folder_name]);
			var meta:Metadata = null;
			try {
				meta = MetadataParser.readHaxelibMetadata(full_path);
			} catch (x:Exception) {
				trace(x.details());
			}

			var x:ListItem = {
				id: folder_name,
				label: meta?.name ?? folder_name,
				description: meta?.description,
				detail: full_path.replace(ctx.globalStorageUri.fsPath,"~")
			};
			return x;
		});
	}

	function setHaxelibFolder(folder_name:String) {
		var full_path = Path.join([fcpkg.getHaxelibRootPath(), folder_name]);
		setHaxelibPath(full_path);
	}

	function setConfigHaxelib() {
		setHaxelibPath(cfg.HAXELIB_PATH);
	}

	function setHaxelibPath(full_path:String) {
		HaxeHelper.checkVshaxeHaxelib(() -> {
			var result = Process.setHaxelibPath(full_path);
			if (!result)
				Interaction.displayError(Language.FAILED_TO_SET_HAXELIB_PATH);
			else {
				cfg.HAXELIB_PATH = full_path;
				trace(full_path);
				trace(cfg.HAXELIB_PATH);
				Vscode.commands.executeCommand("haxe.restartLanguageServer");
			}
		}, (reason) -> {
			Interaction.displayError(reason);
		});
	}
}
