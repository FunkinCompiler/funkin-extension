package runner;

@:keep
class Main  {
	public static function main() {
		trace("It's working");
		vscode.debugAdapter.DebugSession.run(FunkinDebugger);
	}
}
