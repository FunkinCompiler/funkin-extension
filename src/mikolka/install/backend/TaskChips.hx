package mikolka.install.backend;

import js.lib.Promise;


typedef ChipTask =  (resolve:Void->Void, deny:String->Void,ctx:TaskChips) -> Void;

class TaskChips {
    var taskChips:Array<ChipTask>;
    var resolve:Any->Void;
    var deny:String->Void;
    public var result:Any = null;
    var taskInsertPos = 0;

    var taskCount = 0;
    private function new(initialChips:Array<ChipTask>,resolve:Any->Void, deny:String->Void) {
        taskChips = initialChips;
        this.resolve = resolve;
        this.deny = deny;
    }
    public static function runChips(initialChips:Array<ChipTask>):Promise<Any> {
        return new Promise((_accept, _reject) -> {
            var obj = new TaskChips(initialChips,_accept,_reject);
            obj.runChipStep();
        });
    }
    public function appendTask(task:ChipTask) {
        taskChips.insert(taskInsertPos,task);
        taskInsertPos++;
    }   
    public function appendManyTasks(tasks:Array<ChipTask>) {
        for (task in tasks){
            appendTask(task);
        }
    }
    private function runChipStep() {
        var nextTask = taskChips.shift();
        if(nextTask != null){
            taskCount++;
            trace('running ${taskCount}/${taskChips.length+1}');
            taskInsertPos = 0;
            nextTask(runChipStep,deny,this);
        }
        else resolve(result);
    }
}