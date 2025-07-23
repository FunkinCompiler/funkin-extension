package mikolka.helpers;

import js.node.child_process.ChildProcess.ChildProcessEvent;
import js.node.buffer.Buffer;
import js.node.stream.Readable.ReadableEvent;
import js.node.ChildProcess;
import js.Node;
import mikolka.vscode.Interaction;

class Process {
	public static function spawnProcess(cmd:String,cwd:String,onExit:(code:Int) ->Void) {	
		Sys.println(cwd+" >>> " + cmd);
		var proc = ChildProcess.spawn(cmd,null,{
			cwd: cwd,
			stdio: Pipe,
			shell: true
		});
		proc.stdout.on(ReadableEvent.Data, (data:Buffer) ->{
			Vscode.debug.activeDebugConsole.append(data.toString("utf-8"));
		});
		proc.stderr.on(ReadableEvent.Data, (data:Buffer) ->{
			Vscode.debug.activeDebugConsole.append(data.toString("utf-8"));
		});
		proc.on(ChildProcessEvent.Exit, (errorCode:Null<Int>, _) -> {
			if(errorCode == null){
				Interaction.displayError("Fatality occurred while running the game!");
				onExit(-1000);
			}
			else onExit(errorCode);
		});
		return proc;
	}

	public static function spawnFunkinGame(cwd:String, execName:String, cmd_prefix:String = "") {

		spawnProcess('$cmd_prefix ./$execName',cwd,(code) ->{
			if(code != 0) Interaction.displayError("Process exited with code: "+code); 
		});

	}
	public static function checkCommand(execName:String,cwd:Null<String> = null,errTitle:String = "Error checking command"):Bool {
        var proc = ChildProcess.spawnSync(execName,{
			cwd: cwd,
		});
		var code = proc.status;
		if( code != 0){
			Interaction.displayErrorAlert(errTitle,proc.output.toString());
		}
		return code == 0;
    }
	public static function isPureHaxelib():Bool {
        var proc = ChildProcess.spawnSync("haxelib list");
		var code = proc.status;
		var out = Std.string(proc.stdout);
		return code == 0 && out.length == 0;
    }
	public static function resolveCommand(command:String):String {
		Sys.println("*>> "+command);
        var proc = ChildProcess.spawnSync(command);
		var code = proc.status;
		var out = proc.stdout;
		return out;
    }
}