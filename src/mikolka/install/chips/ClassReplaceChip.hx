package mikolka.install.chips;

import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;
import mikolka.install.backend.TaskChips;

using StringTools;

class ClassReplaceChip {
    var haxePatchesPath:String;
    var haxelib_path:String;
    var writeLine:String ->Void;

    public function new(haxePatchesPath:String,haxelib_path:String,writeLine:String ->Void) {
        this.haxePatchesPath = haxePatchesPath;
        this.haxelib_path = haxelib_path;
        this.writeLine = writeLine;
    }
    public function task(resolve:Void->Void, deny:String->Void,ctx:TaskChips) {
        var full_path = Path.join([haxelib_path,haxePatchesPath]);
        FileManager.scanDirectory(full_path,onFile,(x) ->{});
        resolve();
    }
    private function onFile(filename:String) {
        trace(filename);
        if(filename.endsWith(".patch")){
            var sourceFileName = filename.substring(0,filename.length-(".patch".length));
            var patchFile = filename;

            if(!FileSystem.exists(Path.join([haxelib_path,sourceFileName]))){
                writeLine('Patch file ${patchFile} doesn\'t have a file to patch! Ignoring it...');
                return;
            }
            var sourceContent = File.getContent(Path.join([haxelib_path,sourceFileName]));
            var patchContent = File.getContent(Path.join([haxelib_path,haxePatchesPath,patchFile]));

            var foundPatches = patchContent.split("-# ");
            var firstLinePattern = ~/([^\n]*)\n(.*)/s;
            if(foundPatches.length > 1){
                foundPatches.shift();
                var replaceContent = sourceContent;

                foundPatches.forEach(s -> {
                    if(!firstLinePattern.match(s)) return;
                    var filePattern = new EReg(firstLinePattern.matched(1),"gm");
                    replaceContent = filePattern.replace(replaceContent,firstLinePattern.matched(2));
                });
                File.saveContent(Path.join([haxelib_path,sourceFileName]),replaceContent);
            }
            else {
                writeLine('Patch file ${patchFile} doesn\'t have a valid patch! It will be ignored.');
            }
        }
        else {
            var sourceFile = Path.join([haxelib_path,filename]);
            if(!FileSystem.exists(sourceFile)){
                writeLine('File ${filename} doesn\'t have a file to replace! Ignoring it...');
                return;
            }
            var replacePatchFile = File.getContent(Path.join([haxelib_path,haxePatchesPath,filename]));

            File.saveContent(sourceFile, replacePatchFile);
        }
    }
}