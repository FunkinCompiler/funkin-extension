package runner;

import haxe.zip.Tools;
import haxe.io.Path;
import haxe.io.Input;
import haxe.zip.Reader;
import sys.FileSystem;
import haxe.crypto.Base64;
import haxe.io.BytesInput;
import sys.io.File;
using StringTools;

class DebugFiles {
	private static final BASE_ZIP = "
    UEsDBBQAAAAAAGylJlsAAAAAAAAAAAAAAAAIAAAAc2NyaXB0cy9QSwMEFAAAAAgAZ6UmWx1HP+fM
    AQAA7wMAABYAAABzY3JpcHRzL0Z1bmtTZXJ2ZXIuaHhjhVPBbtswDL3rK4hcZmeFku0YowOKdbkN
    KNb2HCgW7QiVJU2SExdD/n20lcRpkKCGYUnkI/n4KDOmGmd9hKo1b8rwNirNnW5rZQL/g9oK+RAC
    xvCI67Z+GhzFKUarDnWKWeruRTXoT07r0FSaV0pjeA8RG76kbXGtXu94pc2ls7FSKlNz3KKJgT+X
    Xrn4qz/cQtLaauS/h6VgbDadMpjCy0YFoBc70TiNkGAQNnZHUUALRAuNMMq1WkSEWjT4JUCIdAiU
    YcZKLUKAJZV7Rr9FT7kiGhkg1YLZDBI/lMnC/jGArfDgsUKPpsRFEoDMrl1rVfbky6isAYO7LCd7
    HwIQWoc+m1DleGA6uYNv8/k8Lwb/KSHcQ5+S76wnEepH5bGM1r9fwPhq5UTcEHrCPf5tKS/KlR+G
    O0lYVUE24rFTIYb8LINEjRFPBbKByb5vxZIWXkkcm7Hmp0fSLRvGtjib2kWL/CPy0F0vpDBybTuU
    x4vRz27t7RuaY9le2Ej37YmmgnKxpF4iNTgvbnF6dXLklA5XmY1J4es9DHCOWjgyjFKdgX7A93yw
    p/APCQY+yXpV4IPvGAmfCZ4euixw48/Mcp7GOuL37Pjdsz37D1BLAwQUAAAACADAoyZb/DsHeOgA
    AABLAQAAEgAAAF9wb2x5bW9kX21ldGEuanNvbk2PT0vEQAzF7/0UoWd3Wv+AuCBSFO97EAURmU5D
    Z9g2U2YyO8iy391M68FLIPm9l7ycK4CaHU9Y76F+TXR0BM9+XtyEAXbwgn0aIWI4YaivinjAaIJb
    2Hkqlg6MqDVJC7MfgH0ZzImc0YyQHVtgizDqGUE0IRG7GbddxhMH1yf2IcqyT5kBnNcqlMRSTrzR
    kXwm6BJbv6VYeQpTwZZ5ifumyTmrH5849agkQpM1G/t0ehwO+S4/vI8f5lCv1ovUr/W+Xty3PBb/
    fmnVvbrdkskr/8m1alW7kckZpLgG6xZtLO5uBFWX6hdQSwECPwMUAAAAAABspSZbAAAAAAAAAAAA
    AAAACAAAAAAAAAAAAAAA7UEAAAAAc2NyaXB0cy9QSwECPwMUAAAACABnpSZbHUc/58wBAADvAwAA
    FgAAAAAAAAAAAAAApIEmAAAAc2NyaXB0cy9GdW5rU2VydmVyLmh4Y1BLAQI/AxQAAAAIAMCjJlv8
    Owd46AAAAEsBAAASAAAAAAAAAAAAAACkgSYCAABfcG9seW1vZF9tZXRhLmpzb25QSwUGAAAAAAMA
    AwC6AAAAPgMAAAAA
    ".replace(" ","").replace("\n","");

	public static function makeSupportMod(mod_path:String) {
		var script_folder = Path.join([mod_path, "mods", "debug"]);

		if (!FileSystem.exists(script_folder))
			extractZip(new BytesInput(Base64.decode(BASE_ZIP)), script_folder);
	}

	public static function extractZip(file:Input, target:String) {
		var zip = Reader.readZip(file);
		FileSystem.createDirectory(target);
		for (node in zip) {
			if (node.crc32 == null || node.crc32 == 0) {
				FileSystem.createDirectory(Path.join([target, node.fileName]));
			} else {
				Tools.uncompress(node);
				File.saveBytes(Path.join([target, node.fileName]), node.data);
			}
		}
	}
}
