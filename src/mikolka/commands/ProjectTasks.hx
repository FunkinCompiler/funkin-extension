package mikolka.commands;

import mikolka.vscode.Interaction;
import mikolka.helpers.LangStrings;
import mikolka.config.FunkCfg;
import haxe.io.Path;
import mikolka.helpers.ZipTools;
import haxe.Http;
import sys.FileSystem;
import sys.io.File;

class ProjectTasks {
    public static function assertTemplateZip(template_url:String):Bool {
        if(!FileSystem.exists("template.zip")){
            var client = new Http(template_url);
            client.request();
            if (client.responseBytes == null){
                return false;
            }
            File.saveBytes("template.zip",client.responseBytes);
        }
        return true;
    }
    public static function task_setupProject(template_url:String) {
        Interaction.requestInput(LangStrings.PROJECT_NAME_PROMPT,(name) ->{
            makeProject(template_url,name);
        });

    }
    public static function makeProject(template_url:String,name:String) {
        Sys.println("Making project...");
        if (assertTemplateZip(template_url)){
            ZipTools.extractZip(File.read("template.zip"),name);
            File.copy(Sys.programPath(),Path.join([name,"compiler.exe"]));
            File.copy("funk.cfg",Path.join([name,"funk.cfg"]));
            if (Sys.systemName() == "Linux"){
                Sys.command('chmod +x \'${Path.join([name,"compiler.exe"])}\'');
            }
            Sys.println("Done!");
        }
        else {
            Sys.println("Couldn't find the mod template!");
        }
    }
}