package mikolka.misc;

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
}
