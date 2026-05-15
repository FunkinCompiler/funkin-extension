package runner.vslice;

import haxe.Json;

enum SyntaxType {
    Variable;
    Value;
    Assign;
    Special;
    Execute;
    Unknown;
}
typedef SyntaxChip = {
    type:SyntaxType,
    value:String
}

class HaxeSyntaxParser {
    public static function exportTokens(tokens:Array<SyntaxChip>) {
        var json_tokens = [];
        for (tk in tokens){
            var type_str = switch(tk.type){
                case Variable: "Var";
                case Assign: "Ass";
                case Value: "Value";
                case Special: "Special";
                case Unknown: "None";
                case Execute: "Exec";
            }
            json_tokens.push({
                "type": type_str,
                "value":tk.value
            });
        }
        return Json.stringify(json_tokens);
    }
    public static function parseExecCommand(command:String):Array<SyntaxChip> {
        var out:Array<SyntaxChip> = [];
        var i = 0;
        var len = command.length;

        function peek():Null<String> {
            return if (i < len) command.charAt(i) else null;
        }
        function next():Null<String> {
            var c = peek();
            if (c != null) i++;
            return c;
        }
        function eatWhile(predicate:String->Bool):String {
            var s = "";
            while (i < len && predicate(command.charAt(i))) {
                s += command.charAt(i);
                i++;
            }
            return s;
        }

        // helpers
        function isIdentStart(c:String):Bool {
            return Std.is(c, String) && (c >= "A" && c <= "Z" || c >= "a" && c <= "z" || c == "_" || c == "-" );
        }
        function isIdentPart(c:String):Bool {
            return isIdentStart(c) || (c >= "0" && c <= "9");
        }

        // skip whitespace and comments
        while (i < len) {
            var c = peek();
            if (c == " " || c == "\t" || c == "\n" || c == "\r") { next(); continue; }
            // line comment
            if (c == "/" && i + 1 < len && command.charAt(i + 1) == "/") {
                i += 2;
                while (i < len && command.charAt(i) != "\n") i++;
                continue;
            }
            // block comment
            if (c == "/" && i + 1 < len && command.charAt(i + 1) == "*") {
                i += 2;
                while (i + 1 < len && !(command.charAt(i) == "*" && command.charAt(i + 1) == "/")) i++;
                i += 2;
                continue;
            }
            break;
        }

        while (i < len) {
            var c = peek();
            // whitespace & comments
            if (c == " " || c == "\t" || c == "\n" || c == "\r") { next(); continue; }
            if (c == "/" && i + 1 < len && command.charAt(i + 1) == "/") {
                i += 2;
                while (i < len && command.charAt(i) != "\n") i++;
                continue;
            }
            if (c == "/" && i + 1 < len && command.charAt(i + 1) == "*") {
                i += 2;
                while (i + 1 < len && !(command.charAt(i) == "*" && command.charAt(i + 1) == "/")) i++;
                i += 2;
                continue;
            }

            // identifier or keyword
            if (isIdentStart(c)) {
                var ident = eatWhile(function(ch) return isIdentPart(ch));
                // lookahead for assignment or call
                // skip spaces
                var save = i;
                while (i < len && StringTools.isSpace(command,i)) i++;
                if (i < len && command.charAt(i) == "=") {
                    // assignment: emit Assign for variable name, and skip '='
                    out.push({ type: SyntaxType.Assign, value: ident });
                    i++; // skip '='

                    // parse right-hand side token (simple: identifier or literal)
                    while (i < len && StringTools.isSpace(command,i)) i++;
                    if (i < len) {
                        var rc = command.charAt(i);
                        if (isIdentStart(rc)) {
                            var rval = eatWhile(function(ch) return isIdentPart(ch));
                            out.push({ type: SyntaxType.Variable, value: rval });
                        } else {
                            // take until comma/semicolon/parens
                            var rval = "";
                            while (i < len) {
                                var cc = command.charAt(i);
                                if (StringTools.isSpace(command,i) || cc == "," || cc == ";" || cc == ")" ) break;
                                rval += cc;
                                i++;
                            }
                            if (rval.length > 0) out.push({ type: SyntaxType.Value, value: rval });
                        }
                    }
                } else if (i < len && command.charAt(i) == "(") {
                    // function call -> Execute
                    out.push({ type: SyntaxType.Execute, value: ident });
                    i = save; // rewind to before skipping spaces so args can be parsed next if desired
                } else {
                    // plain identifier
                    out.push({ type: SyntaxType.Variable, value: ident });
                    i = save; // already at save or further; keep cursor
                }
                continue;
            }

            // operators like '=' alone
            if (c == "=") {
                next();
                out.push({ type: SyntaxType.Special, value: "=" });
                continue;
            }

            // string literal
            if (c == "\"" || c == "'") {
                var quote = c;
                next();
                var lit = "";
                while (i < len) {
                    var ch = next();
                    if (ch == null) break;
                    if (ch == "\\" && i < len) {
                        // escape
                        lit += ch;
                        lit += next();
                        continue;
                    }
                    if (ch == quote) break;
                    lit += ch;
                }
                out.push({ type: SyntaxType.Value, value: quote + lit + quote });
                continue;
            }

            // numbers
            if (c >= "0" && c <= "9") {
                var num = eatWhile(function(ch) return (ch >= "0" && ch <= "9") || ch == "." );
                out.push({ type: SyntaxType.Value, value: num });
                continue;
            }

            // punctuation: skip or add as variable
            if (";,(){}".indexOf(c) >= 0) {
                out.push({ type: SyntaxType.Special, value: String.fromCharCode(command.charCodeAt(i)) });
                next();
                continue;
            }

            // fallback: consume one charSpecial
            out.push({ type: SyntaxType.Unknown, value: next() });
        }

        return out;
    }
}