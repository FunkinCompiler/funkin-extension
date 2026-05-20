package mikolka.vscode.providers.diagnostics;

import vscode.Range;
using StringTools;

typedef ImportLine = {
	var line:String;
	var importName:String;
	var position:Int;
}

class SourceFileAnalyst {
    private var classImportPos:Int = 0;
    private var classImportLine:String = "";
    public final importLines:Array<ImportLine>;
    public var classNameRange:Range = null;

    public function new(sourceText:String) {
        var lines = sourceText.split("\n");
        importLines = getImports(lines);
        calculateClassImportRange();
    }

    function getImports(lines:Array<String>):Array<ImportLine> {
		var matches:Array<ImportLine> = [];
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
			} else if (importLine.contains("class ")){
                classImportPos = lineCounter;
                classImportLine = importLine;
				break;
            }
			lineCounter++;
		}
		return matches;
	}
    function calculateClassImportRange() {
        final classRegex:EReg = ~/class +([a-zA-z]*)/g;
        if(classRegex.match(classImportLine)){
            var className = classRegex.matched(1);
            var clsNameStart = classImportLine.indexOf(className);
            var clsNameEnd = clsNameStart+className.length;
            classNameRange = new Range(classImportPos,clsNameStart,classImportPos,clsNameEnd);
        }
    }
}