package mikolka.vscode;

import js.lib.Promise.Thenable;
import vscode.CancellationTokenSource;
import vscode.CancellationToken;
import vscode.Pseudoterminal;
import vscode.TerminalDimensions;
import vscode.EventEmitter;

typedef TerminalOptions = {
    dimensions:TerminalDimensions,
    token:CancellationToken,
    writeLine:(String) -> Void
}
class OutputTerminal  {
    public static function makeTerminal(action:(TerminalOptions) -> Void):Pseudoterminal {
        var writeEmitter = new EventEmitter<String>();
        var exitEmitter = new EventEmitter<Int>();
        var token = new CancellationTokenSource();
        return {
            onDidWrite: writeEmitter.event,
            onDidClose: exitEmitter.event,
            open: initialDimensions -> {
                trace("Running action:");
                action({
                    dimensions: initialDimensions,
                    token: token.token,
                    writeLine: makeWriterCallback(writeEmitter)
                });
                exitEmitter.fire(0);
                token.dispose();
            },
            close: () -> {
                token.cancel();
                trace("TODO: implement this");
            }
        };
    }
    // JS time!!!
    static function makeWriterCallback(event:EventEmitter<String>):(String) -> Void {
        return (input:String) ->{
            event.fire(input);
            event.fire("\n\r");
        };
    }
}