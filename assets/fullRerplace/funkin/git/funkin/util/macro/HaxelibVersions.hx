package funkin.util.macro;

import haxe.io.Path;

@:nullSafety
class HaxelibVersions
{
  public static function getLibraryVersions():Array<String>
  {
    // `#if display` is used for code completion. In this case returning an
    // empty string is good enough; We don't want to call functions on every hint.
    var commitHash:Array<String> = [];
    return commitHash;
  }

}