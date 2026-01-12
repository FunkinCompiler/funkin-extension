package mikolka.install.backend;

class FunkinPatchRules {
    public static var BLACKLIST:Array<String> = ["../funkin/ui/debug", "../funkin/play/notes/notekind/NoteKind.hx"];
    public static final FUNKIN_REGEX:Map<EReg, String> = [
    ~/@:hscriptClass\nclass +(.*) +extends +(.*) +implements .* +{}/g => "class $1 extends $2 {
  //! mock calls
  //* real implementations are handled by polymod

  /**
   * Initializes a scripted class instance using the given scripted class name and constructor arguments.
   * @param className Name of the target class extending $1 type
   * @param args List of argument of a scripted constructor. olny the first one seems to work?
   * @return $1
   */
  public static function init(className:String,...args:Any):$1 {
    return null;
  }
  /**
   * Polymod function: Calls a requested function from this scripted class using given arguments
   *
   * You must enable `mockPolymodCalls` to use this function
   * @param funcName Name of the target function
   * @param args Arguments for that function
   */
  public function polymodExecFunc(funcName:String, args:Array<Dynamic> = null):Dynamic {
    //* mock call. Once build it should be replaced with
    //* 'scriptCall'
    return null;
  }
	/**
	 * Returns the value of a custom field of the scripted class, by the given name.
	 	 *
	 	 * @param fieldName The name of the field to return.
	 	 * @return The value of the field, if any.
	 */
	 public function scriptGet(fieldName:String):Dynamic{return null;};
	/**
	 * Sets the value of a custom field of the scripted class, by the given name.
	 *
	 * @param fieldName The name of the field to set.
	 * @param value The value to set.
	 * @return The newly set value.
	 */
	 public function scriptSet(fieldName:String, value:Dynamic):Dynamic{return null; }
   /**
    * Returns a list of all the scripted classes which extend $1.
    * @return Array<String> THE list
    */
   public static function listScriptClasses():Array<String> {return null; }
}",
    ~/^  var (.*):(.*)/gm => "  public var $1:$2",
    ~/^  static var (.*):(.*)/gm => "  public static var $1:$2",
    ~/^  static final (.*):(.*)/gm => "  public static final $1:$2",
    ~/^  var (.*)/gm => "  public var $1",
    ~/^  static var (.*)/gm => "  public static var $1",
    ~/^  static final (.*)/gm => "  public static final $1",
 // ~/^  public static final (.*):(.*)/gm => "  public static var $1:$2",
    ~/^  function (.*)\((.*)\)/gm => "  public function $1($2)",
    ~/^  private function (.*)\((.*)\):/gm => "  public function $1($2):",
    ~/^  static function (.*)\((.*)\):/gm => "  public static function $1($2):"
  ]; 
}