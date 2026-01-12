package mikolka.install.backend;

import js.lib.RegExp;
import haxe.Exception;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import haxe.Json;

using StringTools;

typedef HmmNode = {
	name:String,
	type:String,
	dir:String,
	ref:String,
	url:String,
	version:String
}

enum HmmLibraryKind {
	GITHUB;
	HAXELIB;
	UNKNOWN;
}

typedef HmmLibrary = {
	type:HmmLibraryKind,
	source:String,
	versionTag:String,
	haxeLibraryName:String
}

class HmmParser {
	var haxelib_path:String;
	var writeLine:String->Void;

	public function new(haxelib_path:String, writeLine:String->Void) {
		this.haxelib_path = haxelib_path;
		this.writeLine = writeLine;
	}

	function readHmmFile():Null<Array<HmmNode>> {
		var hmmFile = Path.join([haxelib_path, "funkin", "git", "hmm.json"]);
		if (!FileSystem.exists(hmmFile)) {
			writeLine(hmmFile + " is absent??");
			return null;
		}
		try {
			var file = File.getContent(hmmFile);
			var deps = Json.parse(file).dependencies;
			trace(deps);
			return cast deps;
		} catch (x:Exception) {
			writeLine(x.details());
			return null;
		}
	}

	public function getLibraries():Null<Array<HmmLibrary>> {
		var hmm = readHmmFile();
		if (hmm == null)
			return null;
		return hmm.map(s -> {
			var kind = switch (s.type) {
				case "haxelib": HAXELIB;
				case "git": GITHUB;
				default: UNKNOWN;
			}
			if (kind == GITHUB) {
				var gitRegexMatch:EReg = ~/https?:\/\/[a-zA-Z0-9_]+\.[a-z]{2,4}\/([\x00-\x7F]+\/[\x00-\x7F]+)/g;
				trace(s.url);
				gitRegexMatch.match(s.url);
				try {
					var matchedUrl = gitRegexMatch.matched(1).replace(".git", "");
                    if(matchedUrl.endsWith("/")) matchedUrl = matchedUrl.substring(0,matchedUrl.length-1);
					return {
						versionTag: kind == GITHUB ? s.ref : s.version,
						type: kind,
						source: matchedUrl,
						haxeLibraryName: s.name.replace(".", ",")
					}
				} catch (x:Exception) {
					writeLine(x.details());
					return {
						versionTag: s.version,
						type: kind,
						source: s.name,
						haxeLibraryName: s.name
					}
				}
			}
			return {
				versionTag: s.version,
				type: kind,
				source: s.name,
				haxeLibraryName: s.name
			}
		});
	}
}
