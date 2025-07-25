package vscode.debugAdapter;

import vscode.debugProtocol.DebugProtocol;

@:jsRequire("vscode-debugadapter", "Message")
extern class Message {
	var seq:Int;
	var type:MessageType;
	function new(type:String):Void;
}

@:jsRequire("vscode-debugadapter", "Response")
extern class Response<T> extends Message {
	var request_seq:Int;
	var success:Bool;
	var command:String;
	function new(request:Request<T>, ?message:String):Void;
}

@:jsRequire("vscode-debugadapter", "Event")
extern class Event<T> extends Message {
	var event:String;
	var body:T;
	function new(event:String, ?body:T);
}
