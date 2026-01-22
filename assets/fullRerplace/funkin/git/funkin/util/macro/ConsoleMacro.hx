package funkin.util.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
#if !macro
import flixel.FlxG;
#end

using haxe.macro.TypeTools;
using haxe.macro.ComplexTypeTools;

class ConsoleMacro
{
  #if !macro
  /**
   * Gets called in `Main.hx` after FlxGame is initalized, and is what we use to easy add debug functions to flixel console
   */
  public static function init():Void
  {
    for (className in classes)
    {
      var classInstance = Type.resolveClass(className);
      if (classInstance != null) FlxG.console.registerClass(classInstance);
    }
  }
  #end

  // Runtime-accessible array of console classes
  public static var classes:Array<String> = [];

  /**
   * Called at runtime to register a class with the console
   */
  public static function registerClass(className:String):Void
  {
    classes.push(className);
    trace("Registered console class: " + className);
  }


}
