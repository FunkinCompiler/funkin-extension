package runner;

import runner.vslice.FunkinPaths;
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
    UEsDBBQAAAAAACJSjVwAAAAAAAAAAAAAAAAGAAAAZGVidWcvUEsDBBQAAAAIAA5SjVxb7xdHtwAA
    AAUBAAAYAAAAZGVidWcvX3BvbHltb2RfbWV0YS5qc29uTY4xC8JADIX3/opws5YWFNRNFMHBzU1E
    zjNoaC9X7nI6iP/dtHVweZC8ly/vXQAYIWnRrMDsMjfEsAm+oxYjTGGL13yHhPGJ0Uz68A2Ti9QJ
    Be5P1uA0bVlH8OEGEvqFz0zOCsKL5AHyQLhbj6CZmFnI48hygSXSNUuISWEn3QG8B1WX9aR/caAm
    tI1d1rOZGbyP6nkA2I4u2iz9ylTlopyPaO3y79RlVVaj05JDTiN5fzTFp/gCUEsDBBQAAAAAACJS
    jVwAAAAAAAAAAAAAAAAOAAAAZGVidWcvc2NyaXB0cy9QSwMEFAAAAAgADlKNXGnb6wHeAgAANwcA
    ABwAAABkZWJ1Zy9zY3JpcHRzL0Z1bmtTZXJ2ZXIuaHhjlVTbbtswDH3PV3B5mVO0aroLBiRrgaxd
    NgwoECzt07AHxaYdLbLkSXIaY8i/j7Zsp87qbkMCWBeS5/CQVMbDDU8QUrHRcsOng4FIM20cxLna
    CMVSHUVCJexWR0unDU6b+zXfIftitWpPYil2KNlc7j5Ne6IstCxo/ZmrSKI5tsqdkOwrxhJDd0/r
    v0T5aIw2x6F0hiqWDLeonGULoxOD1n4stz02N9zxxPB0qcMNunLXtT4Cp28ukS1DIzKH0W21fTKT
    TOaJUJYykppHM2vR2Rtc5cmiuugDqGl5gH+hckShzk6hYz4lqun5yckATuBuLSzQH3c8zSQVvfIE
    u9YPFA/oA05DypXIcskdQsJTfGnBOtpYinA+CCW3FuZEZIlmi4ZiOVSRha4gg18DgC03YDBGgyrE
    SUOmOS9FmfRqQ2ZZvpIiLJMOndAKFD4EIzovQwPYPEMTDL0kZ6FOM0F9cGYrlOEpXIzH49G0MvVY
    cFlGgB7EoLLdl7ia0jIiwgOyVtcGSYKgqs3kUWkOfNpECacZFmYwEdY9y7Pk5KUJRjXfcoLa7jGY
    EqGZlB+KuyLDoId/7SpiCF60VFiolaJhwmgEfxwGw4tX79iYfhdE4/V4/KaOUSnLujnXV+fnsKSB
    W+kdRnPKo5zSsqFWRm9QPSfgfRYdBPSbJ2UsEzhQXRXUd7MtF5KvqFGvYDyqrLyt7ySLP0nygw+x
    ju7v5kFN2RtlvKh7oHyyWMaNxYA8WyOtKiLXPHO5waC298N42rizLZc52tpp3xKuCrbBwrIfuXWL
    8sXBiM3fdslampMKJBjStNFknfnGJPW/fW+J+DPmP0EL1Wj7SNIO4boznaHQp+B5TmbG8OK9P7zq
    alzZw+UlDIktNWKXag+JYw6HjP4Xvq9HKRfl0TpVq2k19ACGFeBwAr5Ah3MPTRd+UV/sm4egAX0w
    wmHZJVU72IqiiIum7qPRsUMsc7tuHon94DdQSwECPwMUAAAAAAAiUo1cAAAAAAAAAAAAAAAABgAA
    AAAAAAAAAAAA7UEAAAAAZGVidWcvUEsBAj8DFAAAAAgADlKNXFvvF0e3AAAABQEAABgAAAAAAAAA
    AAAAAO2BJAAAAGRlYnVnL19wb2x5bW9kX21ldGEuanNvblBLAQI/AxQAAAAAACJSjVwAAAAAAAAA
    AAAAAAAOAAAAAAAAAAAAAADtQREBAABkZWJ1Zy9zY3JpcHRzL1BLAQI/AxQAAAAIAA5SjVxp2+sB
    3gIAADcHAAAcAAAAAAAAAAAAAACkgT0BAABkZWJ1Zy9zY3JpcHRzL0Z1bmtTZXJ2ZXIuaHhjUEsF
    BgAAAAAEAAQAAAEAAFUEAAAAAA==

    ".replace(" ","").replace("\n","");

	public static function makeSupportMod(cwd_path:String) {
    trace("mac: "+cwd_path);
    var script_folder = Path.join([FunkinPaths.getModFolderPath(cwd_path), "debug"]);

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
