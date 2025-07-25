package vscode.debugAdapter.testSupport;

import js.lib.Promise;
import js.lib.RegExp;
import js.node.ChildProcess.ChildProcessSpawnOptions;
import vscode.debugProtocol.DebugProtocol;
import haxe.extern.EitherType;

typedef ILocation = {
	var path:String;
	var line:Int;
	var ?column:Int;
	var ?verified:Bool;
}

typedef IPartialLocation = {
	var ?path:String;
	var ?line:Int;
	var ?column:Int;
	var ?verified:Bool;
}

@:jsRequire("vscode-debugadapter-testsupport", "DebugClient")
extern class DebugClient {
	var defaultTimeout:Int;

	/**
		Creates a DebugClient object that provides a promise-based API to write
		debug adapter tests.
		A simple mocha example for setting and hitting a breakpoint in line 15 of a program 'test.js' looks like this:

		var dc;
		setup( () => {
			dc = new DebugClient('node', './out/node/nodeDebug.js', 'node');
			return dc.start();
		});
		teardown( () => dc.stop() );

		test('should stop on a breakpoint', () => {
			return dc.hitBreakpoint({ program: 'test.js' }, 'test.js', 15);
		});
	**/
	function new(runtime:String, executable:String, debugType:String, ?spawnOptions:ChildProcessSpawnOptions, ?enableStderr:Bool);

	/**
		Starts a new debug adapter and sets up communication via stdin/stdout.
		If a port number is specified the adapter is not launched but a connection to
		a debug adapter running in server mode is established. This is useful for debugging
		the adapter while running tests. For this reason all timeouts are disabled in server mode.
	**/
	function start(?port:Int):Promise<Dynamic>;

	/**
		Shutdown the debuggee and the debug adapter (or disconnect if in server mode).
	**/
	function stop():Promise<Dynamic>;

	// ---- protocol requests -------------------------------------------------------------------------------------------------
	function initializeRequest(?args:InitializeRequestArguments):Promise<InitializeResponse>;
	function configurationDoneRequest(?args:ConfigurationDoneArguments):Promise<ConfigurationDoneResponse>;
	function launchRequest(args:LaunchRequestArguments):Promise<LaunchResponse>;
	function attachRequest(args:AttachRequestArguments):Promise<AttachResponse>;
	function restartRequest(args:RestartArguments):Promise<RestartResponse>;
	function terminateRequest(?args:TerminateArguments):Promise<TerminateResponse>;
	function disconnectRequest(?args:DisconnectArguments):Promise<DisconnectResponse>;
	function setBreakpointsRequest(args:SetBreakpointsArguments):Promise<SetBreakpointsResponse>;
	function setFunctionBreakpointsRequest(args:SetFunctionBreakpointsArguments):Promise<SetFunctionBreakpointsResponse>;
	function setExceptionBreakpointsRequest(args:SetExceptionBreakpointsArguments):Promise<SetExceptionBreakpointsResponse>;
	function dataBreakpointInfoRequest(args:DataBreakpointInfoArguments):Promise<DataBreakpointInfoResponse>;
	function setDataBreakpointsRequest(args:SetDataBreakpointsArguments):Promise<SetDataBreakpointsResponse>;
	function continueRequest(args:ContinueArguments):Promise<ContinueResponse>;
	function nextRequest(args:NextArguments):Promise<NextResponse>;
	function stepInRequest(args:StepInArguments):Promise<StepInResponse>;
	function stepOutRequest(args:StepOutArguments):Promise<StepOutResponse>;
	function stepBackRequest(args:StepBackArguments):Promise<StepBackResponse>;
	function reverseContinueRequest(args:ReverseContinueArguments):Promise<ReverseContinueResponse>;
	function restartFrameRequest(args:RestartFrameArguments):Promise<RestartFrameResponse>;
	function gotoRequest(args:GotoArguments):Promise<GotoResponse>;
	function pauseRequest(args:PauseArguments):Promise<PauseResponse>;
	function stackTraceRequest(args:StackTraceArguments):Promise<StackTraceResponse>;
	function scopesRequest(args:ScopesArguments):Promise<ScopesResponse>;
	function variablesRequest(args:VariablesArguments):Promise<VariablesResponse>;
	function setVariableRequest(args:SetVariableArguments):Promise<SetVariableResponse>;
	function sourceRequest(args:SourceArguments):Promise<SourceResponse>;
	function threadsRequest():Promise<ThreadsResponse>;
	function modulesRequest(args:ModulesArguments):Promise<ModulesResponse>;
	function evaluateRequest(args:EvaluateArguments):Promise<EvaluateResponse>;
	function stepInTargetsRequest(args:StepInTargetsArguments):Promise<StepInTargetsResponse>;
	function gotoTargetsRequest(args:GotoTargetsArguments):Promise<GotoTargetsResponse>;
	function completionsRequest(args:CompletionsArguments):Promise<CompletionsResponse>;
	function exceptionInfoRequest(args:ExceptionInfoArguments):Promise<ExceptionInfoResponse>;
	function customRequest<T>(command:String, ?args:Dynamic):Response<T>;

	// ---- convenience methods -----------------------------------------------------------------------------------------------

	/**
		Returns a promise that will resolve if an event with a specific type was received within some specified time.
		The promise will be rejected if a timeout occurs.
	**/
	function waitForEvent<T>(eventType:String, ?timeout:Int):Promise<Event<T>>;

	/**
		Returns a promise that will resolve if an 'initialized' event was received within some specified time
		and a subsequent 'configurationDone' request was successfully executed.
		The promise will be rejected if a timeout occurs or if the 'configurationDone' request fails.
	**/
	function configurationSequence():Promise<Dynamic>;

	/**
		Returns a promise that will resolve if a 'initialize' and a 'launch' request were successful.
	**/
	function launch(launchArgs:Dynamic):Promise<LaunchResponse>;

	/**
		Returns a promise that will resolve if a 'stopped' event was received within some specified time
		and the event's reason and line number was asserted.
		The promise will be rejected if a timeout occurs, the assertions fail, or if the 'stackTrace' request fails.
	**/
	function assertStoppedLocation(reason:String, expected:{?path:EitherType<String, RegExp>, ?line:Int, ?column:Int}):Promise<StackTraceResponse>;

	/**
		Returns a promise that will resolve if enough output events with the given category have been received
		and the concatenated data match the expected data.
		The promise will be rejected as soon as the received data cannot match the expected data or if a timeout occurs.
	**/
	function assertOutput<T>(category:String, expected:String, ?timeout:Int):Promise<Event<T>>;

	function assertPath(path:String, expected:EitherType<String, RegExp>, ?message:String):Void;

	// ---- scenarios ---------------------------------------------------------------------------------------------------------

	/**
		Returns a promise that will resolve if a configurable breakpoint has been hit within some time
		and the event's reason and line number was asserted.
		The promise will be rejected if a timeout occurs, the assertions fail, or if the requests fails.
	**/
	function hitBreakpoint(launchArgs:Dynamic, location:ILocation, ?expectedStopLocation:IPartialLocation,
		?expectedBPLocation:IPartialLocation):Promise<Dynamic>;
}
