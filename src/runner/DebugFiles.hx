package runner;

import runner.vslice.FunkinPaths;
import haxe.zip.Tools;
import haxe.io.Path;
import haxe.io.Input;
import haxe.zip.Reader;
import sys.FileSystem;
import haxe.crypto.Base64;
import haxe.io.BytesInput;
import sys.io.File;
using StringTools;

class DebugFiles {
	private static final BASE_ZIP = "
    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
    SwUGAAAAAAQABAAAAQAArwkAAAAA

    ".replace(" ","").replace("\n","");

	public static function makeSupportMod(cwd_path:String) {
        trace("mac: "+cwd_path);
        var script_folder = Path.join([FunkinPaths.getModFolderPath(cwd_path), "debug"]);

            if (!FileSystem.exists(script_folder))
                extractZip(new BytesInput(Base64.decode(BASE_ZIP)), script_folder);
	}

	public static function extractZip(file:Input, target:String) {
		var zip = Reader.readZip(file);
		FileSystem.createDirectory(target);
		for (node in zip) {
			if (node.crc32 == null || node.crc32 == 0) {
				FileSystem.createDirectory(Path.join([target, node.fileName]));
			} else {
				Tools.uncompress(node);
				File.saveBytes(Path.join([target, node.fileName]), node.data);
			}
		}
	}
}
