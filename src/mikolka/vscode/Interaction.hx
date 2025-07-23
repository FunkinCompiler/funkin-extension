package mikolka.vscode;

class Interaction {

	public static function displayError(msg:String) {
		Vscode.window.showErrorMessage(msg);
	}
	public static function displayErrorAlert(title:String,message:String) {
		Vscode.window.showErrorMessage(title,{
			modal: true,
			detail: message
		});
	}

	// Returns the input from user (or null if canceled)
	public static function requestInput(prompt:String,next:(input:Null<String>) -> Void) {
		Vscode.window.showInputBox({
			title: prompt
		}).then(next,(out) ->{
			displayError("Action canceled!");
		});
	}

	public static function requestConfirmation(prompt:String,onYes:() -> Void,onNo:() -> Void) {
		Vscode.window.showWarningMessage(prompt,"Yes","No").then((result) -> {
			if(result == "Yes"){
				onYes();
			}
			else if(result == "No"){
				onNo();
			}
			else Interaction.displayError("Action aborted!");
		});
	}

	public static function showPressToContinue(prompt:String = "[FIXME] Press any key to continue") {
		Vscode.window.showWarningMessage(prompt);
	}

}
