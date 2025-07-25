package mikolka.helpers;

import vscode.Uri;
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

	public static function safelyCopyFile(from:String, to:String) {
		FileSystem.createDirectory(Path.directory(to));
		File.copy(from, to);
	}

	/**
		Converts given target to the path from the current workspace folder,
		or `null` if no folder is opened.
	**/
	public static function getProjectPath(target:String):Null<String> {
		if(Vscode.workspace.workspaceFolders.length == 0) return null;
		return Path.join([Vscode.workspace.workspaceFolders[0].uri.fsPath,target]);
	}

	/**
		CChecks iof the given target exists relative to the opened folder
	**/
	public static function doesTargetExist(target:String):Bool {
		var path = getProjectPath(target);
		return path != null && FileSystem.exists(path);
	}



}
