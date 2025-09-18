package mikolka.vscode.providers;

import vscode.Range;
import vscode.Diagnostic;
import vscode.DiagnosticCollection;
import vscode.TextDocument;

using StringTools;

typedef ImportLine = {
	var line:String;
	var importName:String;
	var position:Int;
}

/**
 * This registry contains all code for checking problems in a source files
 */
class DiagnosticRegistry {
	/**
	 * This has all currently blacklisted classes from use
	 **/
	final importRegex = [

        ~/^cpp.Lib/ => "Attaching binaried to FNF is disabled within mods",
        ~/^haxe.Unserializer/ => "Mods are not allowed to resolve classes on their own",
        ~/^flixel.util.FlxSave/ => "There was a one very scary method..",
        ~/^extension\.(.*)/ => "Android extensions are disabled within mods",
        ~/^lime.system.(JNI|CFFI|System)/ => "Attaching binaried to FNF is disabled within mods",
        ~/^openfl.Lib/ => "Mods are not allowed to resolve classes on their own",
        ~/^openfl.system.ApplicationDomain/ => "Mods are not allowed to resolve classes on their own",
        ~/^openfl.net.SharedObject/ => "Mods are not allowed to resolve classes on their own",
        ~/^openfl.desktop.NativeProcess/ => 
            "Spawning processes is disallowd within mods. Launch FNF with a companion app if you need external system access.",
        ~/^funkin.util.macro.EnvironmentConfigMacro/ => "Reading build secrets is disallowed",
        ~/^polymod\.(.*)/ => "Use 'PolymodHandler' if you need access to mod list",
        ~/^hscript\.(.*)/ => "Interpreting custom haxe code is disallowed",
        // `funkin.util.macro.*`
        // CompiledClassList's get function allows access to sys and Newgrounds classes
            // None of the classes are suitable for mods anyway
        ~/^io.newgrounds.\.(.*)/ => "Use 'NewgroundsClient' (sandboxed) if you need \"read\" access to NG data",
        // `sys.*`
        // Access to system utilities such as the file system.
        ~/^sys\.(.*)/ => "Mods are not allowed to access system (Use companion apps to bypass this)",
        ~/^Sys/ => "Mods are not allowed to access system (Use companion apps to bypass this)",
        ~/^funkin.util.macro\.(.*)/ => "Some bypasses used this class, so it's banned from use in mods",

    ];

	var problemsReporter:DiagnosticCollection;

	public function new(context:vscode.ExtensionContext) {
		problemsReporter = Vscode.languages.createDiagnosticCollection("Funkin");

		Vscode.workspace.onDidOpenTextDocument(requestImportCheck);
		Vscode.workspace.onDidSaveTextDocument(requestImportCheck);
	}

	/**
	 * Request a given file to be checked against any known blacklisted imports
	 * 
	 * If found, a new diagnostic data will be made internally to display them to the user
	 * @param file 
	 */
	public function requestImportCheck(file:TextDocument) {
		if (file.languageId != "haxe")
			return;
		var text = file.getText();
		var warnings = new Array<Diagnostic>();

		for (importLine in getImports(text)) {
			var warningMsg = findBlacklistClause(importLine.importName);
			if (warningMsg == null)
				continue;

			var range = new Range(importLine.position, 0, importLine.position, importLine.line.length);
			warnings.push(new Diagnostic(range, 'Blacklisted import: ${warningMsg}', Warning));
		}
		problemsReporter.set(file.uri, warnings);
	}

	function findBlacklistClause(importName:String):Null<String> {
		for (x in importRegex.keys()) {
			if (x.match(importName))
				return importRegex[x];
		}
		return null;
	}

	/**
	 * @see https://code.haxe.org/category/beginner/regular-expressions.html
	 */
	function getImports(input:String):Array<ImportLine> {
		var matches:Array<ImportLine> = [];
		var lines = input.split("\n");
		var lineCounter = 0;
		for (line in lines) {
			var importLine = line.trim();
			if (importLine.startsWith("import ")) {
				final importRegex:EReg = ~/import +([a-zA-z.]*) *;/gm;
				if (importRegex.match(importLine)) {
					matches.push({
						line: line,
						position: lineCounter,
						importName: importRegex.matched(1)
					});
				}
			} else if (importLine.contains("class "))
				break;
			lineCounter++;
		}
		return matches;
	}
}
