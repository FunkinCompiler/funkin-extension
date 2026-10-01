package mikolka.config;

import haxe.Exception;
import haxe.DynamicAccess;
import haxe.io.Path;
import sys.io.File;
import sys.FileSystem;
import haxe.Json;
using mikolka.utils.JsonUtils;

typedef Metadata = {
    name:String,
    version:String,
    description:String,
    hxmlFile:Null<String>,
    cppiaHxmlFile:Null<String>,
    importBlacklist:DynamicAccess<String>
}

class MetadataParser {
    public static function readHaxelibMetadata(haxelibTarget:String):Null<Metadata> {
        var metadata_path = Path.join([haxelibTarget,"metadata.json"]);
        if(!FileSystem.exists(metadata_path)) return null;
        var obj:Metadata = Json.parse(File.getContent(metadata_path));
        return obj;
    }
    public static function readActiveMetadata():Metadata {
        var path = VsCodeConfig.instance.HAXELIB_PATH;
        var base:Metadata = {
            name: "No name",
            version: Main.MANIFEST_VERSION,
            description: "No description",
            hxmlFile:null,
            cppiaHxmlFile: null,
            importBlacklist: new DynamicAccess<String>()
        };
        try{
            var loaded_metadata = readHaxelibMetadata(path);
            var result = base.mergeWithJson(loaded_metadata); 
            if(VsCodeConfig.instance.DEBUG) trace(result);
            return result;
        }
        catch(x:Exception){
            Interaction.displayError(Language.failedToReadMetadata(x.message));
            return base;
        }

    }
    public static function extractRegexRules(obj:Metadata) {
        var result = new Map<EReg,String>();
        for (key => value in obj.importBlacklist) {
            result.set(new EReg(key,""),value);
        }
        return result;
    }
}