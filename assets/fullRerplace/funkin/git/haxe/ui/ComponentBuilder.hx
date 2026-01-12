package haxe.ui;

import haxe.io.Path;
import haxe.macro.Expr;

// can we disable this??
@:access(haxe.ui.macros.ComponentMacros)
class ComponentBuilder {
    static var libPath:String = null;
    static function resolveCommand(command:String):String {
        var proc = new sys.io.Process(command);
		var code = proc.exitCode(true);
		var out = proc.stdout.readLine();
		return out;
    }
    macro public static function build(resourcePath:String, params:Expr = null):Array<Field> {
        if(libPath == null){
            libPath = Path.join([resolveCommand("haxelib config"),"funkin/git"]);
        }
        return haxe.ui.macros.ComponentMacros.buildCommon(Path.join([libPath,resourcePath]), params);
    }
    
    macro public static function fromFile(filePath:String, params:Expr = null):Expr {
        return haxe.ui.macros.ComponentMacros.buildComponentCommon(filePath, params);
    }
    
    macro public static function fromString(source:String, params:Expr = null):Expr {
        return haxe.ui.macros.ComponentMacros.buildFromStringCommon(source, params);
    }
    
}