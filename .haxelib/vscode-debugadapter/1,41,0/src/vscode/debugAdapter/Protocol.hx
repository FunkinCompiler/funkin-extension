package vscode.debugAdapter;

import vscode.debugProtocol.DebugProtocol;

typedef DebugProtocolMessage = {}

@:jsRequire("vscode-debugadapter", "Disposable0")
extern class Disposable0 {
	function dispose():Any;
}

typedef Event0<T> = (listener:(e:T) -> Any, ?thisArg:Any) -> Disposable0;

@:jsRequire("vscode-debugadapter", "ProtocolServer")
extern class ProtocolServer {
	function sendEvent<T>(event:Event<T>):Void;
	function sendResponse<T>(response:Response<T>):Void;
	function sendRequest<T>(command:String, args:Dynamic, timeout:Float, cb:(response:Response<T>) -> Void):Void;

	/** vscode.DebugAdapter methods **/
	var onDidSendMessage(default, null):Event0<DebugProtocolMessage>;

	function dispose():Any;
	function handleMessage(message:ProtocolMessage):Void;
}
