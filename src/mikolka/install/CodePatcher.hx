package mikolka.install;

import haxe.io.Path;
import mikolka.install.backend.TaskChips;
import mikolka.install.backend.FunkinPatchRules;
import sys.io.File;

using StringTools;

// Patcher
// !! make sure to put "polymodExecFunc" in Module.hx
// !! THIS IS NOT AUTOMATIC
//"haxe -main CodePatcher --interp  "
class CodePatcher
{
    var haxelib_path:String;
    public function new(haxelib_path:String) {
        this.haxelib_path = haxelib_path;
    }
  public function patchFnfCode(resolve:Void->Void, deny:String->Void,ctx:TaskChips)
  {
    FileManager.scanDirectory(Path.join([haxelib_path,"funkin","git","funkin"]),inspectFile,(x) ->{});

    // For haxe UI
    resolve();
  }

  private function inspectFile(path:String)
  {
    var fullPath:String = Path.join([haxelib_path,"funkin","git","funkin",path]);
    for (x in FunkinPatchRules.BLACKLIST)
    {
      if (path.startsWith(x)) return;
    }
    var content = File.getContent(fullPath);
    trace(fullPath);

    for (x in FunkinPatchRules.FUNKIN_REGEX.keys())
    {
      content = x.replace(content, FunkinPatchRules.FUNKIN_REGEX[x]);
    }
    File.saveContent(fullPath, content);
  }
}