package runner.server;
typedef Message = {
	final ?event:String;
	var   ?id:Int;
	final ?params:Array<String>;
}

typedef Error = {
	final code:Int;
	final message:String;
}
