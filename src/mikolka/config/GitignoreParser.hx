package mikolka.config;

import haxe.Exception;
import sys.FileSystem;
import haxe.io.Path;
import sys.io.File;

class GitignoreParser {
	private var patterns:Array<GitignorePattern> = [];

	public static function loadCurrentIgnores(mod_root:String):Null<GitignoreParser> {
		if (FileSystem.exists(Path.join([mod_root, ".funkignore"]))) {
			try {
				var ret = new GitignoreParser();
				ret.loadFromFile(Path.join([mod_root, ".funkignore"]));
				ret.patterns.push({
					pattern: ".funkignore",
					isAnchored: false,
					isDirectoryOnly: false,
					isNegation: false
				});
				return ret;
			} catch (x:Exception) {
				return null;
			}
		}
		return null;
	}

	/**
	 * Load and parse a .gitignore file
	 */
	public function loadFromFile(filePath:String):Void {
		try {
			var content = File.getContent(filePath);
			parseContent(content);
		} catch (e:Dynamic) {
			throw 'Failed to read .gitignore file: $filePath';
		}
	}

	/**
	 * Parse .gitignore content directly from a string
	 */
	public function parseContent(content:String):Void {
		patterns = [];
		var lines = content.split('\n');

		for (line in lines) {
			line = StringTools.trim(line);

			// Skip empty lines and comments
			if (line.length == 0 || line.charAt(0) == '#') {
				continue;
			}

			var isNegation = false;

			// Handle negation patterns (!)
			if (line.charAt(0) == '!') {
				isNegation = true;
				line = line.substring(1);
			}

			var isDirectoryOnly = false;

			// Handle directory-only patterns (trailing /)
			if (line.charAt(line.length - 1) == '/') {
				isDirectoryOnly = true;
				line = line.substring(0, line.length - 1);
			}

			// Handle anchor patterns (leading /)
			var isAnchored = false;
			if (line.charAt(0) == '/') {
				isAnchored = true;
				line = line.substring(1);
			}

			patterns.push({
				pattern: line,
				isNegation: isNegation,
				isDirectoryOnly: isDirectoryOnly,
				isAnchored: isAnchored
			});
		}
	}

	/**
	 * Check if a relative path (file or directory) is ignored by checking the file itself
	 * and all parent directories.
	 * @param relativePath The relative path to check (e.g., "src/main.hx" or "build/")
	 * @param isDirectory Whether the path is a directory (optional, defaults to false for files)
	 * @return true if the path or any of its parent directories should be ignored
	 */
	public function isIgnored(relativePath:String, isDirectory:Bool = false):Bool {
		// Normalize path separators
		relativePath = StringTools.replace(relativePath, '\\', '/');
		if (relativePath.charAt(0) == '/') {
			relativePath = relativePath.substring(1);
		}

		// Remove trailing slash for consistency
		if (relativePath.length > 0 && relativePath.charAt(relativePath.length - 1) == '/') {
			relativePath = relativePath.substring(0, relativePath.length - 1);
			isDirectory = true;
		}

		// Check the file/directory itself
		if (matchesIgnoreRules(relativePath, isDirectory)) {
			return true;
		}

		// Check all parent directories
		var pathParts = relativePath.split('/');
		var currentPath = '';
		for (i in 0...pathParts.length - 1) {
			currentPath += pathParts[i];

			// Check if this directory is ignored
			if (matchesIgnoreRules(currentPath, true)) {
				return true;
			}

			currentPath += '/';
		}

		return false;
	}

	/**
	 * Internal method to check if a specific path matches any ignore rules
	 */
	private function matchesIgnoreRules(path:String, isDirectory:Bool):Bool {
		var ignored = false;

		patterns.forEach(rule -> {
			// Skip if this rule is for directories only and path isn't a directory
			if (rule.isDirectoryOnly && !isDirectory) {
				return;
			}

			// Check if the pattern matches
			if (patternMatches(rule.pattern, path, rule.isAnchored)) {
				ignored = !rule.isNegation;
			}
		});

		return ignored;
	}

	/**
	 * Internal method to match gitignore patterns against paths
	 */
	private function patternMatches(pattern:String, path:String, isAnchored:Bool):Bool {
		// Handle ** (matches any number of directories)
		if (pattern.indexOf('**') != -1) {
			return matchGlobDoublestar(pattern, path, isAnchored);
		}

		// For anchored patterns, match from the start
		if (isAnchored) {
			return matchGlob(pattern, path);
		}

		// For non-anchored patterns, try matching the filename and any subdirectory
		if (matchGlob(pattern, path)) {
			return true;
		}

		// Check if pattern matches any segment of the path
		var pathParts = path.split('/');
		for (part in pathParts) {
			if (matchGlob(pattern, part)) {
				return true;
			}
		}

		return false;
	}

	/**
	 * Match a glob pattern with ** support
	 */
	private function matchGlobDoublestar(pattern:String, path:String, isAnchored:Bool):Bool {
		var parts = pattern.split('**');
		var pathIndex = 0;

		// Match the first part
		if (parts[0].length > 0) {
			var firstPart = parts[0];
			if (firstPart.charAt(firstPart.length - 1) == '/') {
				firstPart = firstPart.substring(0, firstPart.length - 1);
			}
			if (!matchGlob(firstPart, path.split('/')[0])) {
				return false;
			}
			pathIndex = firstPart.length + 1;
		}

		// Match subsequent parts
		for (i in 1...parts.length) {
			var part = parts[i];
			if (part.length > 0 && part.charAt(0) == '/') {
				part = part.substring(1);
			}

			if (part.length > 0) {
				var foundIndex = path.indexOf(part, pathIndex);
				if (foundIndex == -1) {
					return false;
				}
				pathIndex = foundIndex + part.length;
			}
		}

		return true;
	}

	/**
	 * Simple glob pattern matching (supports *, ?, [abc])
	 */
	private function matchGlob(pattern:String, text:String):Bool {
		var pIndex = 0;
		var tIndex = 0;
		var pLen = pattern.length;
		var tLen = text.length;

		while (pIndex < pLen && tIndex < tLen) {
			var pChar = pattern.charAt(pIndex);

			if (pChar == '*') {
				// Match zero or more characters
				if (pIndex == pLen - 1) {
					return true; // * at the end matches everything
				}

				var nextPattern = pattern.substring(pIndex + 1);
				while (tIndex <= tLen) {
					if (matchGlob(nextPattern, text.substring(tIndex))) {
						return true;
					}
					tIndex++;
				}
				return false;
			} else if (pChar == '?') {
				// Match any single character
				pIndex++;
				tIndex++;
			} else if (pChar == '[') {
				// Character class
				var endBracket = pattern.indexOf(']', pIndex);
				if (endBracket == -1) {
					return false;
				}

				var charset = pattern.substring(pIndex + 1, endBracket);
				var tChar = text.charAt(tIndex);

				if (charset.indexOf(tChar) == -1) {
					return false;
				}

				pIndex = endBracket + 1;
				tIndex++;
			} else if (pChar == text.charAt(tIndex)) {
				pIndex++;
				tIndex++;
			} else {
				return false;
			}
		}

		// Check if we've consumed both pattern and text
		while (pIndex < pLen && pattern.charAt(pIndex) == '*') {
			pIndex++;
		}

		return pIndex == pLen && tIndex == tLen;
	}

	public function new() {}
}

/**
 * Internal structure for gitignore patterns
 */
private typedef GitignorePattern = {
	pattern:String,
	isNegation:Bool,
	isDirectoryOnly:Bool,
	isAnchored:Bool
};
