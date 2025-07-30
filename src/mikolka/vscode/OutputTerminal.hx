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
        var token = new CancellationTokenSource();
        return {
            onDidWrite: writeEmitter.event,
            open: initialDimensions -> {
                action({
                    dimensions: initialDimensions,
                    token: token.token,
                    writeLine: makeWriterCallback(writeEmitter)
                });
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