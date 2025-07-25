package vscode.debugAdapter;

import haxe.extern.EitherType;
import vscode.debugAdapter.Protocol;
import vscode.debugProtocol.DebugProtocol;
import vscode.debugProtocol.DebugProtocol.Source as TSource;
import vscode.debugAdapter.Messages;

@:jsRequire("vscode-debugadapter", "Source")
extern class Source {
	var name:String;
	var path:String;
	var sourceReference:Int;
	function new(name:String, path:String, id:Int = 0, ?origin:String, ?data:Dynamic):Void;
}

@:jsRequire("vscode-debugadapter", "Scope")
extern class Scope {
	var name:String;
	var variablesReference:Int;
	var namedVariables:Int;
	var indexedVariables:Int;
	var expensive:Bool;
	function new(name:String, reference:Int, expensive:Bool = false):Void;
}

@:jsRequire("vscode-debugadapter", "StackFrame")
extern class StackFrame {
	var id:Int;
	var source:Source;
	var line:Int;
	var column:Int;
	var name:String;
	function new(i:Int, nm:String, ?src:Source, ln:Int = 0, col:Int = 0):Void;
}

@:jsRequire("vscode-debugadapter", "Thread")
extern class Thread {
	var id:Int;
	var name:String;
	function new(id:Int, name:String):Void;
}

@:jsRequire("vscode-debugadapter", "Variable")
extern class Variable {
	var name:String;
	var value:String;
	var variablesReference:Int;
	function new(name:String, value:String, ref:Int = 0, ?indexedVariables:Int, ?namedVariables:Int):Void;
}

@:jsRequire("vscode-debugadapter", "Breakpoint")
extern class Breakpoint {
	var id:Int;
	var verified:Bool;
	var message:String;
	var source:TSource;
	var line:Int;
	var column:Int;
	var endLine:Int;
	var endColumn:Int;
	function new(verified:Bool, ?line:Int, ?column:Int, ?source:Source);
}

@:jsRequire("vscode-debugadapter", "Module")
extern class Module {
	var id:EitherType<Int, String>;
	var name:String;
	function new(id:EitherType<Int, String>, name:String):Void;
}

@:jsRequire("vscode-debugadapter", "CompletionItem")
extern class CompletionItem {
	var label:String;
	var start:Int;
	var length:Int;
	function new(label:String, start:Int, length:Int = 0):Void;
}

@:jsRequire("vscode-debugadapter", "StoppedEvent")
extern class StoppedEvent extends Event<TStoppedEvent> {
	var reason:String;
	var threadId:Int;
	var text:String;
	var allThreadsStopped:Bool;
	function new(reason:String, ?threadId:Int, ?exception_text:String):Void;
}

@:jsRequire("vscode-debugadapter", "ContinuedEvent")
extern class ContinuedEvent extends Event<TContinuedEvent> {
	function new(threadId:Int, ?allThreadsContinued:Bool):Void;
}

@:jsRequire("vscode-debugadapter", "InitializedEvent")
extern class InitializedEvent extends Event<{}> {
	function new():Void;
}

@:jsRequire("vscode-debugadapter", "TerminatedEvent")
extern class TerminatedEvent extends Event<TTerminatedEvent> {
	function new(?restart:Bool):Void;
}

@:jsRequire("vscode-debugadapter", "OutputEvent")
extern class OutputEvent extends Event<TOutputEvent> {
	function new(output:String, category:OutputEventCategory = Console):Void;
}

@:jsRequire("vscode-debugadapter", "ThreadEvent")
extern class ThreadEvent extends Event<TThreadEvent> {
	function new(reason:String, threadId:Int):Void;
}

@:jsRequire("vscode-debugadapter", "BreakpointEvent")
extern class BreakpointEvent extends Event<TBreakpointEvent> {
	function new(reason:BreakpointEventReason, breakpoint:Breakpoint):Void;
}

@:jsRequire("vscode-debugadapter", "ModuleEvent")
extern class ModuleEvent extends Event<TModuleEvent> {
	function new(reason:ModuleEventReason, module:Module):Void;
}

@:jsRequire("vscode-debugadapter", "LoadedSourceEvent")
extern class LoadedSourceEvent extends Event<TLoadedSourceEvent> {
	function new(reason:LoadedSourceEventReason, source:Source):Void;
}

@:jsRequire("vscode-debugadapter", "CapabilitiesEvent")
extern class CapabilitiesEvent extends Event<TCapabilitiesEvent> {
	function new(capabilities:Capabilities):Void;
}

@:jsRequire("vscode-debugadapter", "ProgressStartEvent")
extern class ProgressStartEvent extends Event<TProgressStartEvent> {
	function new(progressId:String, title:String, ?message:String):Void;
}

@:jsRequire("vscode-debugadapter", "ProgressUpdateEvent")
extern class ProgressUpdateEvent extends Event<TProgressUpdateEvent> {
	function new(progressId:String, ?message:String):Void;
}

@:jsRequire("vscode-debugadapter", "ProgressEndEvent")
extern class ProgressEndEvent extends Event<TProgressEndEvent> {
	function new(progressId:String, ?message:String):Void;
}

enum abstract ErrorDestination(Int) {
	var User = 1;
	var Telemetry = 2;
}

@:jsRequire("vscode-debugadapter", "DebugSession")
extern class DebugSession extends ProtocolServer {
	static function run(debugSession:Class<DebugSession>):Void;
	function new(?obsolete_debuggerLinesAndColumnsStartAt1:Bool, ?obsolete_isServer:Bool):Void;
	function setDebuggerPathFormat(format:String):Void;
	function setDebuggerLinesStartAt1(enable:Bool):Void;
	function setDebuggerColumnsStartAt1(enable:Bool):Void;
	function setRunAsServer(enable:Bool):Void;
	function shutdown():Void;
	private function sendErrorResponse<T>(response:Response<T>, codeOrMessage:EitherType<Int, Message>, ?format:String, ?variables:Dynamic,
		dest:ErrorDestination = User):Void;
	private function runInTerminalRequest(args:RunInTerminalRequestArguments, timeout:Float, cb:(response:RunInTerminalResponse) -> Void):Void;
	private function dispatchRequest<T>(request:Request<T>):Void;
	private function initializeRequest(response:InitializeResponse, args:InitializeRequestArguments):Void;
	private function disconnectRequest(response:DisconnectResponse, args:DisconnectArguments):Void;
	private function launchRequest(response:LaunchResponse, args:LaunchRequestArguments):Void;
	private function attachRequest(response:AttachResponse, args:AttachRequestArguments):Void;
	private function terminateRequest(response:TerminateResponse, args:TerminateArguments):Void;
	private function restartRequest(response:RestartResponse, args:RestartArguments):Void;
	private function setBreakPointsRequest(response:SetBreakpointsResponse, args:SetBreakpointsArguments):Void;
	private function setFunctionBreakPointsRequest(response:SetFunctionBreakpointsResponse, args:SetFunctionBreakpointsArguments):Void;
	private function setExceptionBreakPointsRequest(response:SetExceptionBreakpointsResponse, args:SetExceptionBreakpointsArguments):Void;
	private function configurationDoneRequest(response:ConfigurationDoneResponse, args:ConfigurationDoneArguments):Void;
	private function continueRequest(response:ContinueResponse, args:ContinueArguments):Void;
	private function nextRequest(response:NextResponse, args:NextArguments):Void;
	private function stepInRequest(response:StepInResponse, args:StepInArguments):Void;
	private function stepOutRequest(responses:StepOutResponse, args:StepOutArguments):Void;
	private function stepBackRequest(response:StepBackResponse, args:StepBackArguments):Void;
	private function reverseContinueRequest(response:ReverseContinueResponse, args:ReverseContinueArguments):Void;
	private function restartFrameRequest(response:RestartFrameResponse, args:RestartFrameArguments):Void;
	private function gotoRequest(response:GotoResponse, args:GotoArguments):Void;
	private function pauseRequest(response:PauseResponse, args:PauseArguments):Void;
	private function sourceRequest(response:SourceResponse, args:SourceArguments):Void;
	private function threadsRequest(response:ThreadsResponse):Void;
	private function terminateThreadsRequest(response:TerminateThreadsResponse, args:TerminateThreadsRequest):Void;
	private function stackTraceRequest(response:StackTraceResponse, args:StackTraceArguments):Void;
	private function scopesRequest(response:ScopesResponse, args:ScopesArguments):Void;
	private function variablesRequest(response:VariablesResponse, args:VariablesArguments):Void;
	private function setVariableRequest(response:SetVariableResponse, args:SetVariableArguments):Void;
	private function setExpressionRequest(response:SetExpressionResponse, args:SetExpressionArguments):Void;
	private function evaluateRequest(response:EvaluateResponse, args:EvaluateArguments):Void;
	private function stepInTargetsRequest(response:StepInTargetsResponse, args:StepInTargetsArguments):Void;
	private function gotoTargetsRequest(responses:GotoTargetsResponse, args:GotoTargetsArguments):Void;
	private function completionsRequest(response:CompletionsResponse, args:CompletionsArguments):Void;
	private function exceptionInfoRequest(response:ExceptionInfoResponse, args:ExceptionInfoArguments):Void;
	private function loadedSourcesRequest(response:LoadedSourcesResponse, args:LoadedSourcesArguments):Void;
	private function dataBreakpointInfoRequest(response:DataBreakpointInfoResponse, args:DataBreakpointInfoArguments):Void;
	private function setDataBreakpointsRequest(response:SetDataBreakpointsResponse, args:SetDataBreakpointsArguments):Void;
	private function readMemoryRequest(response:ReadMemoryResponse, args:ReadMemoryArguments):Void;
	private function disassembleRequest(response:DisassembleResponse, args:DisassembleArguments):Void;
	private function cancelRequest(response:CancelResponse, args:CancelArguments):Void;
	private function breakpointLocationsRequest(response:BreakpointLocationsResponse, args:BreakpointLocationsArguments):Void;
	private function setInstructionBreakpointsRequest(response:SetInstructionBreakpointsResponse, args:SetInstructionBreakpointsArguments):Void;
	private function customRequest<T>(command:String, response:Response<T>, args:Dynamic):Void;
	private function convertClientLineToDebugger(line:Int):Int;
	private function convertDebuggerLineToClient(line:Int):Int;
	private function convertClientColumnToDebugger(line:Int):Int;
	private function convertDebuggerColumnToClient(line:Int):Int;
	private function convertClientPathToDebugger(clientPath:String):String;
	private function convertDebuggerPathToClient(debugPath:String):String;
}
