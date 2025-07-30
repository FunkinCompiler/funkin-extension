package mikolka.helpers;

import sys.io.File;
import haxe.zip.Entry;
import haxe.io.Path;
import sys.FileSystem;

class FileManager {
	public static function deleteDirRecursively(path:String):Void {
		scanDirectory(path, s -> FileSystem.deleteFile(Path.join([path, s])), s -> FileSystem.deleteDirectory(Path.join([path, s])));
	}

	public static function isManifestPresent(modAssetsDir:String):Bool {
		var manifestPath = '$modAssetsDir/_polymod_meta.json';

		if (!FileSystem.exists(manifestPath)) {
			return false;
		}
		return true;
	}

	public static function scanDirectory(prefix:String, onFile:String->Void, onDir:String->Void, path:String = "") {
		var fullPath = Path.join([prefix, path]);
		if (FileSystem.exists(fullPath) && FileSystem.isDirectory(fullPath)) {
			var entries = FileSystem.readDirectory(fullPath);
			for (entry in entries) {
				if (FileSystem.isDirectory(fullPath + '/' + entry)) {
					scanDirectory(prefix, onFile, onDir, path + "/" + entry);
					onDir(path + '/' + entry);
				} else {
					onFile(path + '/' + entry);
				}
			}
		}
	}

	public static function isFolderEmpty(path:String) {
		return FileSystem.readDirectory(path).length == 0;
	}
	public static function safelyCopyFile(from:String, to:String) {
		FileSystem.createDirectory(Path.directory(to));
		File.copy(from, to);
	}

	/**
		Converts given target to the path from the current workspace folder,
		If not opened, request a user to select one.
	**/
	// Copied from vshaxe extension
	public static function getProjectPath(onResult:(String) -> Void) {
		switch Vscode.workspace.workspaceFolders {
			case null | []:
				Vscode.window.showOpenDialog({
					canSelectFolders: true,
					canSelectFiles: false
				}).then(folders -> {
					if (folders != null && folders.length > 0) {
						Vscode.commands.executeCommand("vscode.openFolder", folders[0]);
						onResult(folders[0].fsPath);
					}
				});
			case [folder]:
				onResult(folder.uri.fsPath);
			case folders:
				final options = {
					placeHolder: "Select a folder to set up a Haxe project into...",
				}
				Vscode.window.showWorkspaceFolderPick(options).then(function(folder) {
					if (folder == null)
						return;
					onResult(folder.uri.fsPath);
				});
		}
	}
	public static function copyRec(from:String, to:String):Void {
		function loop(src, dst) {
			final fromPath = from + src;
			final toPath = to + dst;
			if (FileSystem.isDirectory(fromPath)) {
				FileSystem.createDirectory(toPath);
				for (file in FileSystem.readDirectory(fromPath))
					loop(src + "/" + file, dst + "/" + file);
			} else {
				File.copy(fromPath, toPath);
			}
		}
		loop("", "");
	}

}
