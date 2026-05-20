package mikolka.vscode.providers.diagnostics;

import haxe.io.Path;
import mikolka.vscode.definitions.DisposableProvider;
import vscode.Range;
import vscode.Diagnostic;
import vscode.DiagnosticCollection;
import vscode.TextDocument;

using StringTools;


/**
 * This registry contains all code for checking problems in a source files
 */
class DiagnosticRegistry extends DisposableProvider {
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
		super(context,
			Vscode.workspace.onDidOpenTextDocument(requestImportCheck),
			Vscode.workspace.onDidSaveTextDocument(requestImportCheck)
		);
	}

	override function dispose() {
		super.dispose();
		problemsReporter.dispose();
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
		var textMetadata = new SourceFileAnalyst(text);
		var warnings = new Array<Diagnostic>();
	
		var fileName = Path.withoutDirectory(file.fileName);
		if(fileName.charCodeAt(0)>=97 && fileName.charCodeAt(0)<=122 && textMetadata.classNameRange != null){
			
			warnings.push(new Diagnostic(textMetadata.classNameRange, 
				'Haxe source file should start with an capital letter!', Warning));
		}


		for (importLine in textMetadata.importLines) {
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
}
