package mikolka.install;

import mikolka.install.backend.TaskChips;

class EnvironmentChecks {
	public function new(writeLine:String->Void) {
		this.writeLine = writeLine;
	}

	var writeLine:String->Void;

	public function checkGit(resolve:Void->Void, deny:String->Void, ctx:TaskChips) {
		writeLine(LangStrings.MSG_SETUP_CHECKING_GIT);
		if (!Process.checkCommand("git -v"))
			deny(LangStrings.SETUP_GIT_ERROR);
		else
			resolve();
	}

	public function checkHaxe(resolve:Void->Void, deny:String->Void, ctx:TaskChips) {
		writeLine(LangStrings.MSG_SETUP_CHECKING_HAXE);
		if (!Process.checkCommand("haxe --version"))
			deny(LangStrings.SETUP_HAXE_ERROR);
		else
			resolve();
	}

	public function checkIfHaxelibIsPure(resolve:Void->Void, deny:String->Void, ctx:TaskChips) {
		writeLine("[SETUP] Checking haxelib..");
		if (!Process.isPureHaxelib()) {
			Interaction.requestConfirmation(LangStrings.SETUP_HAXELIB_ERROR_TITLE, LangStrings.SETUP_HAXELIB_ERROR, () -> {
				writeLine("Continuing!");
				resolve();
			}, () -> {
				deny("Funkin setup aborted!");
			});
		} else
			resolve();
	}
}
