package runner.server;

import vscode.debugAdapter.DebugSession.CompletionItem;
import runner.vslice.HaxeSyntaxParser;
import js.Lib;
import runner.vslice.SupportModDto.CompletionResult;
import runner.vslice.SupportModDto.CommandResult;
import haxe.Json;
import js.node.net.Socket;
import js.node.net.Server;
import js.node.Net;

using StringTools;

class DebugServer {
    private final server:Server;
    private var connectedDebugger:Connection;
    public function new() {
        // This would start the debug server
		server = Net.createServer(onConnected);
        server.maxConnections = 1;
    }
    public function start() {
        server.listen(3004, function() {
            trace("Debug server active");
		});
    }
    private function onConnected(socket:Socket) {
        if(socket != null || socket != Lib.undefined){
            connectedDebugger?.close();
            connectedDebugger = null;
        }
        connectedDebugger = new Connection(socket);
    }

    public function softRestartGame() {
        connectedDebugger?.sendCommand({event: "restart",params: []});
    }
    public function sendCmdCommand(command:String, ?callback:CommandResult->Void) {
        var command_tokens = HaxeSyntaxParser.exportTokens(HaxeSyntaxParser.parseExecCommand(command));
        connectedDebugger?.sendCommand({event: "execute",params: [command_tokens]},(struct -> { 
            if(struct.event != "execute_resp"){
                callback({wasSuccess: false,data: "Invalid response type!"});
                return;
            }
            if(struct.params.length != 2){
                callback({wasSuccess: false,data: "Invalid params array received!"});
                return;
            }
            var isError = struct.params[0] == "true";
            callback({wasSuccess: !isError,data: struct.params[1]});
        }));
    }
    /**
    * Partial_command is the part before the text pointer. Remember this when requesting completions! 
    **/
    public function listVariablesCommand(partial_command:String, ?callback:CompletionResult->Void) {
        var tokens = HaxeSyntaxParser.parseExecCommand(partial_command);
        if(partial_command.endsWith(" ") || tokens.filter(s -> s.type == Assign || s.type == Execute).length != 0) {
            callback({completions: [],fuzzyFieldLength:0});
            return;
        }
        var context_chain = HaxeSyntaxParser.exportTokens(tokens);
        connectedDebugger?.sendCommand({event: "list_variables",params: [context_chain]},(struct -> { 
            if(struct.event != "list_variables_resp" || struct.params.length < 2){
                callback({completions: [],fuzzyFieldLength:0});
                return;
            }
            if(struct.params[0] == "true"){
                callback({completions: [],fuzzyFieldLength:0});
                return;
            }
            var result = Json.parse(struct.params[1]);
            callback(result);
        }));
    }
}