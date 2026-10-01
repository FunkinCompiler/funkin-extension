package mikolka.helpers;

import haxe.DynamicAccess;
import haxe.extern.EitherType;
import js.node.Buffer;
import js.node.ChildProcess;
import mikolka.vscode.ui.Interaction;

class Process {
	public static function runCurl(sourceUrl:String, target_file:String, cwd:Null<String> = null, onInput:String->Void, onComplete:Void->Void) {
		runCommand('curl', ['-L', '-o', target_file.shellPath(), sourceUrl], cwd, onInput, onComplete);
	}

	public static function checkCommand(execName:String, cwd:Null<String> = null):Bool {
		trace(cwd);
		var proc = ChildProcess.spawnSync(execName, {
			cwd: cwd,
			stdio: Pipe,
			shell: true
		});
		var code = proc.status;
		if (code != 0) {
			Interaction.displayError(proc.output.toString());
		}
		return code == 0;
	}

	public static function setHaxelibPath(path:String):Bool {
		var proc = ChildProcess.spawnSync(HaxeHelper.getHaxelibExecutable(), ["setup", path.shellPath()], {
			stdio: Pipe,
			shell: true
		});
		var code = proc.status;
		if (code != 0) {
			Interaction.displayError(proc.output.toString());
		}
		return code == 0;
	}

	public static function runCommand(execName:String, args:Array<String> = null, cwd:Null<String> = null, onInput:String->Void, onComplete:Void->Void) {
		trace(cwd);
		var proc = ChildProcess.spawn(execName.shellPath(), args, {
			cwd: cwd,
			stdio: Pipe,
			shell: true
		});

		// proc.on('SIGINT',);
		proc.on('exit', onComplete);
		proc.stdout.on("data", (data) -> {
			onInput(data);
		});
		proc.stderr.on("data", (data) -> {
			onInput(data);
		});
	}

	public static function spawnSyncProcess(execName:String, args:Array<String> = null):String {
		var out = "";

		var proc = ChildProcess.spawnSync(execName.shellPath(), args, {
			stdio: Pipe,
			shell: true
		});

		if (hadData(proc.stdout))
			out += Std.string(proc.stdout);

		if (hadData(proc.stderr))
			out += Std.string(proc.stderr);

		return out;
	}

	private static function hadData(x:EitherType<Buffer, String>):Bool {
		if (x == null)
			return false;
		if (Std.isOfType(x, Buffer)) {
			var z = cast(x, Buffer);
			return z.length != 0;
		} else {
			var z = cast(x, String);
			return z.length != 0;
		}
	}

	public static function resolveCommand(command:String):String {
		trace("*>> " + command);
		var proc = ChildProcess.spawnSync(command, {
			cwd: Sys.getCwd(),
			stdio: Pipe,
			shell: true
		});
		var code = proc.status;
		var out = Std.string(proc.stdout);
		return out;
	}
}
