package mikolka.vscode;

import vscode.Uri;
import vscode.ThemeIcon;
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
	
	public static function requestDirectory(prompt:String,initialValue:String,next:(inputPath:String) -> Void,onCancel:Void -> Void) {
		var box = Vscode.window.createInputBox();
		var acceptedValue = false;
		box.buttons = [{
			tooltip: "Browse",
			iconPath: ThemeIcon.Folder
		}];
		box.prompt = prompt;
		box.value = initialValue;
		box.placeholder = "Enter a path to a directory (or use the folder button to pick one)";
		box.onDidTriggerButton(e -> {
			if(e.tooltip == "Browse"){
				box.busy = true;
				Vscode.window.showOpenDialog({
					canSelectFolders: true,
					canSelectFiles: false
				}).then(folders -> {
					if (folders != null && folders.length > 0) {
						box.value = folders[0].fsPath;
					}
					box.busy = false;
				});
			}
		});
		box.onDidAccept(e -> {
			acceptedValue = true;
			next(box.value);
			box.dispose();
		});
		box.ignoreFocusOut = true;
		box.onDidHide(e -> {
			if(!acceptedValue) {
				onCancel();
				box.dispose();
			}
		});
		box.show();
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
