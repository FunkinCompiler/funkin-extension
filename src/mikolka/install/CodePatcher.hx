package mikolka.install;

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

  public static function patchFnfCode(resolve:Void->Void, deny:String->Void,ctx:TaskChips)
  {
    FileManager.scanDirectory("../funkin",inspectFile,(x) ->{});

    // For haxe UI
    resolve();
  }

  private static function inspectFile(path:String)
  {
    for (x in FunkinPatchRules.BLACKLIST)
    {
      if (path.startsWith(x)) return;
    }
    var content = File.getContent(path);
    trace(path);

    for (x in FunkinPatchRules.FUNKIN_REGEX.keys())
    {
      content = x.replace(content, FunkinPatchRules.FUNKIN_REGEX[x]);
    }
    File.saveContent(path, content);
  }
}