package mikolka.config;

import sys.FileSystem;
import sys.io.File;
using StringTools;

class FunkCfg {
    private static var DEFAULT_MAP:Map<String,String> =[
        "game_path" => "../funkinGame",
        "game_mod_name" => "workbench",
        "mod_fnfc_folder" => "fnfc_files",
        "mod_hx_folder" => "source/mod/",
        "mod_content_folder" => "mod_base",
        "template_remote_src" => "https://raw.githubusercontent.com/FunkinCompiler/template-binaries/refs/heads/main/0.6.3.zip",
    ];
    
    private var map:Map<String,String>;
    public function new(cfg_path:String = "funk.cfg") {
        map = loadFile(cfg_path);
    }
    private function getKey(key:String) {
        if(!map.exists(key)) return DEFAULT_MAP[key];
        return map[key];
    }

    public var GAME_PATH(get,null):String;
    function get_GAME_PATH():String {
        return getKey("game_path");
    }
    public var GAME_MOD_NAME(get,null):String;
    function get_GAME_MOD_NAME():String {
        return getKey("game_mod_name");
    }
    public var MOD_FNFC_FOLDER(get,null):String;
    function get_MOD_FNFC_FOLDER():String {
        return getKey("mod_fnfc_folder");
    }
    public var MOD_HX_FOLDER(get,null):String;
    function get_MOD_HX_FOLDER():String {
        return getKey("mod_hx_folder");
    }
    public var MOD_CONTENT_FOLDER(get,null):String;
    function get_MOD_CONTENT_FOLDER():String {
        return getKey("mod_content_folder");
    }
    public var TEMPLATE_REMOTE_SRC(get,null):String;
    function get_TEMPLATE_REMOTE_SRC():String {
        return getKey("template_remote_src");
    }


    public static function loadFile(cfg_path:String) {
        if(!FileSystem.exists(cfg_path)) {
            Sys.println("No config! Creating a new one.");
            saveFile(cfg_path,DEFAULT_MAP);
            return DEFAULT_MAP;
        }

        var lines = File.getContent(cfg_path).split("\n");
        var map = new Map<String,String>();
        for (line in lines){
            if(line.contains("=")){
                var seg = line.split("=");
                if(seg.length != 2) {
                    Sys.println("Malfolded line in config: "+line);
                    continue;
                }
                map.set(seg[0],seg[1]);
            }
        }
        return map;
    }
    public static function saveFile(cfg_path:String,map:Map<String,String>) {
        var text = "";
        for( x in map.keyValueIterator()){
            text += x.key+"="+x.value+"\n";
        }
        File.saveContent(cfg_path,text);
    }
}