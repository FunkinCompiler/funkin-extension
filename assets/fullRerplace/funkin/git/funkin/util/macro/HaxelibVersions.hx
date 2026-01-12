package funkin.util.macro;

import haxe.io.Path;

@:nullSafety
class HaxelibVersions
{
  public static macro function getLibraryVersions():haxe.macro.Expr.ExprOf<Array<String>>
  {
    // `#if display` is used for code completion. In this case returning an
    // empty string is good enough; We don't want to call functions on every hint.
    var commitHash:Array<String> = [];
    return macro $v{commitHash};
  }

  #if (macro)
  @SuppressWarnings('checkstyle:Dynamic')
  public static function formatHmmData():Array<String>
  {
    var result:Array<String> = [];

    var hmmData:Dynamic = haxe.Json.parse(sys.io.File.getContent(#if ios '../../../../../' + #end 'hmm.json'));
    var dependencies:Array<Dynamic> = cast hmmData.dependencies;
    for (library in dependencies)
    {
      switch (library.type)
      {
        case 'haxelib':
          result.push('${library.name} haxelib(${library.version ?? 'None'})');
        case 'git':
          result.push('${library.name} git(${library.url}/${library.dir ?? ''}:${library.ref ?? 'None'}');
        case 'mercurial':
          result.push('${library.name} mercurial(${library.url}/${library.dir ?? ''}:${library.ref ?? 'None'})');
        case 'dev':
          result.push('${library.name} dev(${library.path})');
        case ty:
          throw 'Unhandled hmm library type ${ty}';
      }
    }

    return result;
  }

  public static function readLibraryCurrentVersion(libraryName:String):String
  {

    return "";
  }
  #end
}