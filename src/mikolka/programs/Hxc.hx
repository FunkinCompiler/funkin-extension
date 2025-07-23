package mikolka.programs;

import mikolka.vscode.Interaction;
import mikolka.helpers.FileManager;
import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;

class Hxc {
	// Once enabled strips "package" line at the beginning of each file
	// (you still need that line even if you disable that)
	public static var stripPackage:Bool = true;

	// Allows you to utilise haxe's safe casts, like "cast (obj,type)"
	public static var convertCasts:Bool = true;

	// Fixes imports not being recognised by polymod (especially enums)
	public static var convertImports:Bool = true;

	// Allows you to utilise mock calls to polymod to fix missing mothod error
	public static var mockPolymodCalls:Bool = true;

	var src_path:String;
	var mod_export_path:String;

	public function new(src_path:String, mod_export_path:String) {
		this.src_path = src_path;
		this.mod_export_path = mod_export_path; // baseGane_modDir, Mod_Directory
	}

	public function processDirectory() {
		FileManager.scanDirectory(src_path, processFile, s -> {});
	}

	public function processFile(file_name:String) {
		var shard = Path.join([src_path, file_name]);

		var filter:EReg = ~/package ([a-z.]+) *;/i;
		var content:String = File.getContent(shard);
		if (!filter.match(content)) {
			Interaction.displayError('File $shard is missing "package" line');
			return;
		}

		var result = stripPackage ? filter.replace(content, "") : content;
		if (convertCasts)
			result = ~/cast *\((.*),.*\)/g.replace(result, "$1"); // strip casts (polymod doesn't need them)
		if (convertImports)
			result = ~/import +([a-zA-z.]*)\.[A-Z]\w+\.([A-Z]\w+);/g.replace(result, "import $1.$2;");
		if (mockPolymodCalls)
			result = ~/\.polymodExecFunc *\((.*),(\W*\[.*\]\W*)\)/g.replace(result, ".scriptCall($1,$2)");

		var filePackage = filter.matched(1).split(".");
		filePackage[0] = Path.join([mod_export_path, 'scripts']);

		var targetDir = Path.join(filePackage);
		FileSystem.createDirectory(targetDir);
		trace(file_name.substr(1));
		File.saveContent(Path.join([targetDir, Path.withoutDirectory(file_name) + "c"]), result);
	}
}
