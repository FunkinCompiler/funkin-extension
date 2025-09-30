package mikolka.vscode.definitions;

import vscode.Disposable;

abstract class DisposableProvider {
    private var disposables:Array<Disposable> = [];
    private var extensionSubscriptions:Array<{function dispose():Void;}>;
    public function new(context:vscode.ExtensionContext,...hook:Disposable) {
        extensionSubscriptions = context.subscriptions;
        for(x in hook) addDisposable(x);
        
    }
    private function addDisposable(item:Disposable) {
        disposables.push(item);
        extensionSubscriptions.push(item);
    }
    public function dispose():Void{
        for(x in disposables){
            extensionSubscriptions.remove(x);
            x.dispose();
        }
    }
}