package mikolka.install.backend;

import js.lib.Promise;
import vscode.ProgressLocation;
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;

class HaxeDownload {
	public static function installHaxe(store:ExternalStorageTools, onValid:Void->Void, onError:String->Void) {
		Vscode.window.withProgress({location: ProgressLocation.Window, title: Language.FUNKIN_IDE_HAXE_INSTALL_STARTED}, (msg, cancel) -> {
			return new Promise((resolve, reject) -> {
				var system_part:Null<String> = switch (Sys.systemName()) {
					case "Windows": "windows-x64";
					case "Linux": "linux-x64";
					case "Mac": "mac-arm";
					case _: null;
				};
				if (system_part == null) {
					reject(Language.HAXE_INSTALL_UNKNOWN_OS);
					return;
				}
				var target_file = Path.join([store.getTempPath(), "haxe.zip"]);
				var curl_out = new StringBuf();
				Process.runCurl('https://github.com/FunkinCompiler/haxe-bin/releases/download/${Main.HAXE_GITHUB_TAG}/${system_part}.zip', target_file, null,
					s -> {
						curl_out.add(s);
					}, () -> {
						if (!FileSystem.exists(target_file)) {
							reject(Language.failedToDownloadCustomHaxe(curl_out.toString()));
							return;
						}
						ZipTools.extractZip(File.read(target_file), store.getCustomHaxeRootPath());
						if (Sys.systemName() != "Windows") {
							var success = Process.checkCommand('chmod +x "${Path.join([store.getCustomHaxeRootPath(), "haxe"])}"', null);
							success = success
								&& Process.checkCommand('chmod +x "${Path.join([store.getCustomHaxeRootPath(), "haxelib"])}"', null);
							if (!success) {
								reject(Language.HAXE_INSTALL_MAKE_EXECUTABLE_FAILED);
								return;
							}
						}
						store.setHaxeVersion(Main.HAXE_VERSION);
						store.clearTempPath();
						resolve(null);
					});
			});
		}).then(_ -> onValid(),onError);
	}
}
