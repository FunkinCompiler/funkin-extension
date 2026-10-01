package mikolka.helpers;

import haxe.io.Path;
import mikolka.install.backend.HaxeDownload;

class HaxeHelper {
	static var store:ExternalStorageTools;

	public static function getHaxelibExecutable():String {
		var haxelib_file = Sys.systemName() == "Windows" ? "haxelib.exe" : "haxelib";
		return Path.join([store.getCustomHaxeRootPath(), haxelib_file]);
	}

	public static function getHaxeExecutable():String {
		var haxe_file = Sys.systemName() == "Windows" ? "haxe.exe" : "haxe";
		return Path.join([store.getCustomHaxeRootPath(), haxe_file]);
	}

	public static function getHaxeStd():String {
		return Path.join([store.getCustomHaxeRootPath(), "std"]);
	}

	public static function activate(context:vscode.ExtensionContext, onComplete:Void->Void) {
		var ext = Vscode.extensions.getExtension("nadako.vshaxe");
		store = context.getGlobalStore();
		if (!ext.isActive) {
			ext.activate().then((x) -> {
				onComplete();
			});
		} else
			onComplete();
	}

	static var installationStarted:Bool = false;

	public static function checkVshaxeHaxelib(onValid:Void->Void, onError:String->Void) {
		var current_version = store.getHaxeVersion();
		if (current_version != Main.HAXE_VERSION && current_version != null) {
			store.clearCustomHaxe();
			current_version = null;
		}

		if (current_version == null) {
			if (installationStarted) {
				onError(Language.HAXE_INSTALL_PENDING);
				return;
			}
			installationStarted = true;
			HaxeDownload.installHaxe(store, () -> {
				installationStarted = false;
				onValid();
			}, s -> {
				installationStarted = false;
				onError(s);
			});
			return;
		}
		installationStarted = false;
		onValid();
	}
}
