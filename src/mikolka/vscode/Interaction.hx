package mikolka.vscode;

import js.lib.Promise.Thenable;

class Interaction {

	public static function displayError(msg:String):Thenable<Any> {
		return Vscode.window.showErrorMessage(msg);
	}
	public static function displayInformation(msg:String):Thenable<Any> {
		return Vscode.window.showInformationMessage(msg);
	}
	public static function displayErrorAlert(title:String,message:String):Thenable<Any> {
		return Vscode.window.showErrorMessage(title,{
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

	public static function requestConfirmation(title:String,prompt:String,onYes:() -> Void,onNo:() -> Void) {
		Vscode.window.showWarningMessage(title,{modal: true,detail: prompt},"Yes","No").then((result) -> {
			if(result == "Yes"){
				onYes();
			}
			else if(result == "No"){
				onNo();
			}
			else Interaction.displayError("Action aborted!");
		});
	}

}
