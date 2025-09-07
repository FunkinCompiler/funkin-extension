package mikolka.helpers;

import haxe.io.Path;
using StringTools;

class FunkinPaths {

    public static function getModFolderPath(game_cwd:String):String {
        if(ismacOSApp(game_cwd))
            return Path.join([game_cwd,"Contents","Resources", "mods"])
        else
		    return Path.join([game_cwd, "mods"]);
    }
    public static function getExecutableFolderPath(game_cwd:String):String {
        if(ismacOSApp(game_cwd))
            return Path.join([game_cwd,"Contents","MacOS"])
        else
		    return Path.normalize(game_cwd);
    }
    private static function ismacOSApp(game_cwd:String):Bool {
        if(game_cwd.endsWith("/"))
            game_cwd = game_cwd.substr(0,game_cwd.length-1);
        return game_cwd.endsWith(".app");
    }
}