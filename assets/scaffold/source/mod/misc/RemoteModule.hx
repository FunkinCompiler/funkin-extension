package mod.misc;

import funkin.modding.events.ScriptEvent.SongTimeScriptEvent;
import funkin.modding.module.Module;

class RemoteModule extends Module
{
  public function new()
  {
    super("remote", 0);
  }

  public function remoteCall(name:String)
  {
    trace("Helllloo!!! " + name);
  }

  public function remoteMulCall(name:String, value:Int)
  {
    trace("Calling " + name + " " + value + " times");
  }

  override function onBeatHit(event:SongTimeScriptEvent)
  {
    super.onBeatHit(event);
    trace("Doki");
  }
}
