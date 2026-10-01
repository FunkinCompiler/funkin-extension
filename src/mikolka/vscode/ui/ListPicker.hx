package mikolka.vscode.ui;

import vscode.Uri;
import haxe.Json;
import haxe.Exception;
import haxe.Http;
import mikolka.config.VsCodeConfig;

import vscode.QuickPickItem;

using mikolka.utils.UIUtils;

// Supports rendering of {@link ThemeIcon theme icons} via the `$(<name>)`-syntax.
typedef ListItem = {
	> QuickPickItem,
	id:String,
	?onSelect:Null<() -> Void>
}

typedef FcpkgManifest = {
	> QuickPickItem,
	url:String,
	position:Int
}

class ListPicker {
	public static function makePickItem(title:String, options:Array<ListItem>, defaultOnSelection:(x:Null<String>) -> Void) {
        var ext = Vscode.window.createQuickPick();
        ext.title = title;
        ext.items = options;
        ext.matchOnDescription = true;
        ext.ignoreFocusOut = true;
        ext.onDidAccept(s -> {
            if(ext.selectedItems.length == 0){
                defaultOnSelection(null);
            }
            else{
                var vItem = ext.selectedItems[0];
                if (vItem.onSelect == null)
					defaultOnSelection(vItem.id);
				else
					vItem.onSelect();
            }
            ext.dispose();
        });
        return ext;
	}
    public static function pickHaxelibFolder(options:Array<ListItem>, onOptionSelection:(x:Null<String>) -> Void,onManualEntry:(path:String) -> Void) {
		var window = makePickItem(Language.SELECT_FUNKIN_PACKAGE_TO_USE,options,onOptionSelection);
		window.configureSelectFileButton(Language.SELECT_HAXELIB_FOLDER,null,false,s -> {
            window.dispose();
            onManualEntry(s);
        });
        window.show();
        return window;
    }

	public static function pickFcpkgUri(title:String, onResult:(target:Null<Uri>) -> Void) {
		var ext = Vscode.window.createQuickPick();
		// TODO Likely a weak point. Fix in case threads are async.
        ext.ignoreFocusOut = true;
		ext.title = title;

		var remoteRequests = VsCodeConfig.instance.FCPKG_SOURCES.mapInto(s -> new Http(s));

		if (remoteRequests.length > 0){
			ext.busy = true;
			ext.totalSteps = remoteRequests.length;
			ext.step = 0;
			remoteRequests.forEach(http -> {
			 
				http.onError = msg -> {
					ext.step += 1;
					trace('For source ${http.url}:  ${msg}');
				}
				http.onData = data -> {
					try {
						var list:Array<FcpkgManifest> = Json.parse(data);
						trace(list);
						var newList = ext.items.concat(list);
						newList.sort((s1,s2) -> s2.position-s1.position);
						ext.items = newList;
						ext.show();
						
					} catch (x:Exception) {
						trace('For source ${http.url}:  ${x.details()}');
					}
					ext.step += 1;
					if (ext.step >= ext.totalSteps)
						ext.busy = false;
				}
	
				http.request();
			});
		}
        ext.onDidAccept(_ -> {
            if(ext.selectedItems.length == 0){
                onResult(null);
            }
            else{
                var vItem = ext.selectedItems[0];
				onResult(Uri.parse(vItem.url));
            }
            ext.dispose();
        });
		ext.configureSelectFileButton(Language.SELECT_FCPKG_FILE,{"Funkin Compiler package":["fcpkg"]},true,fsPath -> {
            var result = Uri.file(fsPath);
			ext.dispose();
			onResult(result);
        },false);
		ext.show();
	}
}

