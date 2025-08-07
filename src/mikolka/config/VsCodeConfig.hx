package mikolka.config;

import vscode.WorkspaceConfiguration;

class VsCodeConfig {
    var projectConfig:WorkspaceConfiguration;
    public function new() {
        projectConfig = Vscode.workspace.getConfiguration();
    }
    public var MOD_NAME(get,null):String;
    function get_MOD_NAME():String {
        return projectConfig.get("funkinCompiler.modName","workbench");
    }    

    public var GAME_PATH(get,null):String;
    function get_GAME_PATH():String {
        return projectConfig.get("funkinCompiler.gamePath","../funkinGame/");
    }

    public var HAXELIB_PATH(get,set):String;
    function get_HAXELIB_PATH():String {
        return projectConfig.get("funkinCompiler.haxelibPath","");
    }
    function set_HAXELIB_PATH(value:String):String {
        projectConfig.update("funkinCompiler.haxelibPath",value,true);
        return value;
    }
}