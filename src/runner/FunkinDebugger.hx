package runner;

import haxe.Json;
import runner.vslice.HaxeSyntaxParser;
import runner.server.DebugServer;
import vscode.DebugAdapter;
import runner.vslice.FunkinPaths;
import sys.FileSystem;
import vscode.debugProtocol.DebugProtocol.InitializeRequestArguments;
import vscode.debugProtocol.DebugProtocol.InitializeResponse;
import vscode.debugAdapter.DebugSession;
import haxe.DynamicAccess;
import js.node.Buffer;
import js.node.ChildProcess;
import js.node.Net;
import js.node.child_process.ChildProcess.ChildProcessEvent;
import js.node.net.Socket.SocketEvent;
import js.node.stream.Readable.ReadableEvent;
import vscode.debugProtocol.DebugProtocol;

using Lambda;
using StringTools;

typedef FNFLaunchRequestArguments = LaunchRequestArguments & {
	final cwd:String;
	final cmd_prefix:String;
	final execName:String;
	final args:Array<String>;
	//final stopOnEntry:Bool;
	// final haxeExecutable:{
	// 	final executable:String;
	// 	final env:DynamicAccess<String>;
	// };
	//final mergeScopes:Bool;
	//final showGeneratedVariables:Bool;
	final trace:Bool; // if set to true sends trace messages as DebugSession.OutputEvents
}

class FunkinDebugger extends DebugSession  {

	public function new() {
		super();
	}

	override function initializeRequest(response:InitializeResponse, args:InitializeRequestArguments) {
		//response.body.supportsSetVariable = true;
		response.body.supportsEvaluateForHovers = true;
		response.body.supportsCompletionsRequest = true;
		//response.body.supportsConditionalBreakpoints = true;
		//response.body.supportsExceptionOptions = true;
		// response.body.exceptionBreakpointFilters = [
		// 	{filter: "all", label: "All Exceptions"},
		// 	{filter: "uncaught", label: "Uncaught Exceptions"}
		// ];
		// response.body.supportsFunctionBreakpoints = true;
		// response.body.supportsConfigurationDoneRequest = true;
		// response.body.supportsCompletionsRequest = true;
		response.body.supportsRestartRequest = true;
		sendResponse(response);
		postLaunchActions = [];
	}

	var server:DebugServer;
	var onProcessTerminate:() ->Void;
	var postLaunchActions:Array<(() -> Void)->Void>;
	var launchArgs:FNFLaunchRequestArguments;

	function executePostLaunchActions(callback) {
		function loop() {
			final action = postLaunchActions.shift();
			if (action == null)
				return callback();
			action(loop);
		}
		loop();
	}

	function exit() {
		sendEvent(new vscode.debugAdapter.DebugSession.TerminatedEvent(false));
	}


	override function restartRequest(response:RestartResponse, args:RestartArguments) {
		// This is a flag for our helper mod
		server.softRestartGame();
		super.restartRequest(response, args);
	}

	override function evaluateRequest(response:EvaluateResponse, args:EvaluateArguments) {
		var command = args.expression;
		server.sendCmdCommand(command,struct -> {
			response.success = struct.wasSuccess;
			if(response.success){
				response.body = {result: struct.data, variablesReference: 0};
			}
			else{
				response.message = struct.data;
			}
			sendResponse(response);
		});
	}
	override function completionsRequest(response:CompletionsResponse, args:CompletionsArguments) {		
		// server.listVariablesCommand(args.text,)
		// response.body = {targets: }
		server.listVariablesCommand(args.text,struct -> {
			response.success = true;
			response.body = {
				targets: []
			};
			for(foundField in struct.completions){
				response.body.targets.push({
					label: foundField.field,
					type: foundField.field_type,
					start: args.column-struct.fuzzyFieldLength
				});
			}
			sendResponse(response);
		});
	}
	// Launch the BF!!!
	override function launchRequest(response:LaunchResponse, args:LaunchRequestArguments) {
		final args:FNFLaunchRequestArguments = cast args;
		launchArgs = args;
		if (launchArgs.trace) {
			haxe.Log.trace = traceToOutput;
		}


		final env = new haxe.DynamicAccess();
		for (key in js.Node.process.env.keys())
			env[key] = js.Node.process.env[key];
		// for (key in args.haxeExecutable.env.keys())
		// 	env[key] = args.haxeExecutable.env[key];

		server = new DebugServer();
		server.start();

		// function onConnected(socket) {
		// 	trace("Haxe connected!");
		// 	connection = new Connection(socket);
		// 	connection.onEvent = onEvent;

		// 	socket.on(SocketEvent.Error, error -> trace('Socket error: $error'));


		// }
		final cwd = args.cwd;
		final execName = args.execName;
		final cmd_prefix = args.cmd_prefix;
		
		final executable_cwd = FunkinPaths.getExecutableFolderPath(args.cwd);
		DebugFiles.makeSupportMod(args.cwd); // This creates a support mod
		spawnProcess('$cmd_prefix ./$execName',executable_cwd,env);
	
		executePostLaunchActions(function() {
				sendEvent(new vscode.debugAdapter.DebugSession.InitializedEvent());
				sendResponse(response);
				// if (args.stopOnEntry) {
				// 	sendEvent(new vscode.debugAdapter.DebugSession.StoppedEvent("entry", 0));
				// }
		});

	}


	public function spawnProcess(cmd:String,cwd:String,env:Null<haxe.DynamicAccess<String>>) {	
		Sys.println(cwd+" >>> " + cmd);
		//final port = server.address().port;
			
		// Vscode.debug.startDebugging(null,{
		// 	{
		// 		type: type,
		// 		name: name,
		// 		request: request
		// 	}
		// });
		var proc = ChildProcess.spawn(cmd,null,{
			cwd: cwd,
			env: env,
			stdio: Pipe,
			shell: true
		});
		proc.stdout.on(ReadableEvent.Data, onStdout);
		proc.stderr.on(ReadableEvent.Data, onStderr);
		proc.on(ChildProcessEvent.Exit, (_, _) -> exit());
		
		onProcessTerminate = () ->{
			proc.kill();
		};
		return proc;
	}


	function onStdout(data:Buffer) {
		sendEvent(new vscode.debugAdapter.DebugSession.OutputEvent(data.toString("utf-8"), Stdout));
	}

	function onStderr(data:Buffer) {
		sendEvent(new vscode.debugAdapter.DebugSession.OutputEvent(data.toString("utf-8"), Stderr));
	}

	override function disconnectRequest(response:DisconnectResponse, args:DisconnectArguments) {
		// for (id => alive in threads) {
		// 	if (alive) {
		// 		sendEvent(new vscode.debugAdapter.DebugSession.ThreadEvent("exited", id));
		// 	}
		// }
		if(onProcessTerminate != null){
			onProcessTerminate();
			onProcessTerminate = null;
		}
		else{
			response.success = false;
			response.message = "No Kill hook found!";
		}
		sendResponse(response);
	}

	function respond<T>(response:Response<T>, error:Null<runner.server.Message.Error>, f:() -> Void) {
		if (error != null) {
			response.success = false;
			response.message = error.message;
		} else {
			response.success = true;
			f();
		}
		sendResponse(response);
	}

		function traceToOutput(value:Dynamic, ?infos:haxe.PosInfos) {
		var msg = Std.string(value);
		if (infos != null && infos.customParams != null) {
			msg += " " + infos.customParams.join(" ");
		}
		msg += "\n";
		sendEvent(new vscode.debugAdapter.DebugSession.OutputEvent(msg));
	}

	function shellEscapeCommand(command:String):String {
		if (!~/[^a-zA-Z0-9_.:\/\\-]/.match(command)) {
			return command;
		}
		if (command.startsWith('"') && command.endsWith('"')) {
			return command;
		}

		return '"' + command.replace('"', '\\"') + '"';
	}

}