package mikolka.install;

import sys.io.File;
import haxe.io.Path;
import mikolka.install.backend.TaskChips;

class FullReplaceTask {
    var haxePatchesPath:String;
    var haxelib_path:String;
    public function new(haxePatchesPath:String,haxelib_path:String) {
        this.haxePatchesPath = haxePatchesPath;
        this.haxelib_path = haxelib_path;
    }
    public function task(resolve:Void->Void, deny:String->Void,ctx:TaskChips) {
        FileManager.scanDirectory(haxePatchesPath,onFile,(x) ->{});
        resolve();
    }
    private function onFile(filename:String) {
        trace(filename);
        File.saveContent(Path.join([haxelib_path,filename]), File.getContent(Path.join([haxePatchesPath,filename])));
    }
}