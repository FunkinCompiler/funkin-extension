package mikolka.helpers;

import js.node.child_process.ChildProcess.ChildProcessEvent;
import js.node.buffer.Buffer;
import js.node.stream.Readable.ReadableEvent;
import js.node.ChildProcess;
import js.Node;
import mikolka.vscode.Interaction;

class Process {
	public static function spawnFunkinGame(cwd:String, execName:String, cmd_prefix:String = "") {

		if(Vscode.debug.activeDebugSession != null) return;
		trace({
			
				type: "run-game",
				name: "Spawn Funkin instance",
				request: "launch",
				cmd_prefix:cmd_prefix,
				execName:execName,
				cwd:cwd
			
		});
		Vscode.debug.startDebugging(null,cast {
				type: "run-game",
				name: "Spawn Funkin instance",
				request: "launch",
				cmd_prefix:cmd_prefix,
				execName:execName,
				cwd:cwd
			
		}).then((sucsess) ->{
			if(!sucsess){
				Vscode.window.showErrorMessage("Funkin failed to funk!",{modal: true});
			}
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