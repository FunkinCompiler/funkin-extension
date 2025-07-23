package mikolka.helpers;

import haxe.zip.Tools;
import haxe.io.Path;
import haxe.io.Input;
import sys.io.FileInput;
import sys.io.File;
import haxe.zip.Reader;
import haxe.io.Output;
import haxe.zip.Entry;
import haxe.io.Bytes;
import sys.FileSystem;

class ZipTools {
    public static function makeZipArchive(target_to_archive:String,result_out:Output) {
        var zip = new haxe.zip.Writer(result_out);
		var nodes = getZipFileEntries(target_to_archive);
		nodes.add(createIgnoreNode());

		zip.write(nodes);
    }
    public static function getZipFileEntries(dir:String, entries:List<Entry> = null, inDir:Null<String> = null) {
		if (entries == null)
			entries = new List<Entry>();
		if (inDir == null)
			inDir = dir;

		FileManager.scanDirectory(dir, s -> {
			var path = haxe.io.Path.join([dir, s]);
			var bytes:haxe.io.Bytes = haxe.io.Bytes.ofData(sys.io.File.getBytes(path).getData());
			var entry:haxe.zip.Entry = {
				fileName: StringTools.replace(path, inDir, ""),
				fileSize: bytes.length,
				fileTime: Date.now(),
				compressed: false,
				dataSize: FileSystem.stat(path).size,
				data: bytes,
				crc32: haxe.crypto.Crc32.make(bytes)
			};
			entries.push(entry);
		}, s -> {});
		return entries;
	}
	public static function extractZip(file:Input,target:String) {
		var zip = Reader.readZip(file);
		FileSystem.createDirectory(target);
		for (node in zip){
			if(node.crc32 == null || node.crc32 == 0){
				FileSystem.createDirectory(Path.join([target,node.fileName]));
			}
			else {
				Tools.uncompress(node);
				File.saveBytes(Path.join([target,node.fileName]),node.data);
			}
		}
	}
    public static function createIgnoreNode():haxe.zip.Entry
        {
          return {
            fileName: ".disable_gb1click",
            fileSize: 0,
            fileTime: Date.now(),
            compressed: false,
            dataSize: 0,
            data: Bytes.alloc(0),
            crc32: haxe.crypto.Crc32.make(Bytes.alloc(0))
          }
        }
}