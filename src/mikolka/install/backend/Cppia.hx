package mikolka.install.backend;

import sys.io.File;
import sys.FileSystem;
import mikolka.config.VsCodeConfig;
import haxe.io.Path;
import mikolka.config.MetadataParser;
import js.lib.Promise;
import vscode.ProgressLocation;

using StringTools;

typedef CppiaMake = {
	sourcePath:String,
	cppiaOutFile:String,
	classesToCompile:Array<String>
}

class Cppia {
	
	public static function compileExportClasses() {
		HaxeHelper.checkVshaxeHaxelib(() -> {
			Vscode.window.withProgress({location: ProgressLocation.Notification, cancellable: false, title: Language.CPPIA_GENERATING_REFERENCE},
				(msg, cancel) -> new Promise((resolve, reject) -> {
					var haxe_bin = HaxeHelper.getHaxeExecutable().shellPath();
					var current_manifest = MetadataParser.readActiveMetadata();
					if (current_manifest.cppiaHxmlFile != null) {
						var hxml_path = Path.join([VsCodeConfig.instance.HAXELIB_PATH, current_manifest.hxmlFile]).shellPath();
						@:privateAccess
						var did_compile = Process.checkCommand('$haxe_bin $hxml_path -D scriptable',VsCodeConfig.instance.HAXELIB_PATH);
						if (did_compile) {
							FileManager.deleteDirRecursively(Path.join([VsCodeConfig.instance.HAXELIB_PATH, "bin"]));
							resolve(null);
						} else
							reject(Language.CPPIA_FAILED_TO_GENERATE);
					} else
						reject(Language.CPPIA_NOT_SUPPORTED);
				}));
		}, s -> {
			Interaction.displayError(s);
		});
	}

	public static function makeCppiaHxml(tools:ExternalStorageTools, args:CppiaMake):Null<String> {
		var current_manifest = MetadataParser.readActiveMetadata();
		if (current_manifest.cppiaHxmlFile != null) {
			var hxml_path = Path.join([VsCodeConfig.instance.HAXELIB_PATH, current_manifest.cppiaHxmlFile]);
			var class_info_path = Path.join([VsCodeConfig.instance.HAXELIB_PATH, "export_classes.info"]);
			var hxml_temp_path = Path.join([tools.getTempPath(), "cppia-make.hxml"]);


            var CLASS_NAMES = args.classesToCompile.join("\n");
            var CLASS_NAMES_ARRAY = '"'+args.classesToCompile.join('","')+'"';
            var CPPIA_SOURCE = args.sourcePath;
            var CPPIA_DLL = class_info_path;
            var CPPIA_OUT = args.cppiaOutFile;
            var DEBUG_FLAG = "-debug";

			var hxml = File.getContent(hxml_path)
			.replace("$CLASS_NAMES_ARRAY", CLASS_NAMES_ARRAY)
                .replace("$CLASS_NAMES", CLASS_NAMES)
                .replace("$CPPIA_SOURCE", CPPIA_SOURCE)
                .replace("$CPPIA_DLL", CPPIA_DLL)
                .replace("$CPPIA_OUT", CPPIA_OUT)
                .replace("$DEBUG_FLAG", DEBUG_FLAG);
			File.saveContent(hxml_temp_path, hxml);
			return hxml_temp_path;
		} else{
            return null;
        }
	}
    public static function buildClassNames(source:String):Array<String> {
        var result = new Array<String>();
        FileManager.scanDirectory(source,s -> {
			var file = s.charAt(0) == "/" ? s.substring(1) : s;
            result.push(Path.withoutExtension(file).replace("/","."));
        },s -> {});
        return result;
    }
}
