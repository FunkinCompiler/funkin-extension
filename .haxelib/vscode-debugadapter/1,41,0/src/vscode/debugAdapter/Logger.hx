package vscode.debugAdapter;

import vscode.debugProtocol.DebugProtocol.OutputEvent;

@:jsRequire("vscode-debugadapter", "LogLevel")
extern enum abstract LogLevel(Int) {
	var Verbose;
	var Log;
	var Warn;
	var Error;
	var Stop;
}

typedef ILogCallback = (outputEvent:OutputEvent) -> Void;

typedef ILogger = {
	function log(msg:String, ?level:LogLevel):Void;
	function verbose(msg:String):Void;
	function warn(msg:String):Void;
	function error(msg:String):Void;
}

@:jsRequire("vscode-debugadapter", "Logger")
extern class Logger {
	function log(msg:String, ?level:LogLevel):Void;
	function verbose(msg:String):Void;
	function warn(msg:String):Void;
	function error(msg:String):Void;
	function dispose():js.lib.Promise<Void>;

	/**
		Set the logger's minimum level to log in the console, and whether to log to the file. Log messages are queued before this is
		called the first time, because minLogLevel defaults to Warn.
	**/
	function setup(consoleMinLogLevel:LogLevel, ?_logFilePath:haxe.extern.EitherType<String, Bool>, prependTimestamp:Bool = true):Void;

	function init(logCallback:ILogCallback, ?logFilePath:String, ?logToConsole:Bool):Void;
}
