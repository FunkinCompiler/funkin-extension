package vscode.debugAdapter;

@:jsRequire("vscode-debugadapter", "LoggingDebugSession")
extern class LoggingDebugSession extends DebugSession {
	function new(?obsolete_logFilePath:Bool, ?obsolete_debuggerLinesAndColumnsStartAt1:Bool, ?obsolete_isServer:Bool):Void;
}
