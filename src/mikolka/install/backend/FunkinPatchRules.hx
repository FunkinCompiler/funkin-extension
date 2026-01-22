package mikolka.install.backend;

class FunkinPatchRules {
    public static var BLACKLIST:Array<String> = [ "../funkin/play/notes/notekind/NoteKind.hx"]; //"../funkin/ui/debug",
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
    // General patches
    ~/^  var (.*):(.*)/gm => "  public var $1:$2",
    ~/^  static var (.*):(.*)/gm => "  public static var $1:$2",
    ~/^  static final (.*):(.*)/gm => "  public static final $1:$2",
    ~/^  var (.*)/gm => "  public var $1",
    ~/^  static var (.*)/gm => "  public static var $1",
    ~/^  static final (.*)/gm => "  public static final $1",
 // ~/^  public static final (.*):(.*)/gm => "  public static var $1:$2",
    ~/^  function (.*)\((.*)\)/gm => "  public function $1($2)",
    ~/^  private function (.*)\((.*)\):/gm => "  public function $1($2):",
    ~/^  static function (.*)\((.*)\):/gm => "  public static function $1($2):",

    // HXML patches
    ~/implements ConsoleClass/gm => "",
    ~/s._asc.fullyQualifiedName/gm => "''",
    ~/@:build\((.*)\)/gm => "// Build file: $1",
    ~/@:envField/gm => "",
    ~/public static final DISCORD_CLIENT_ID:Null<String>;/gm => "public static var DISCORD_CLIENT_ID:Null<String> = \"\";",

    ~/class ChartEditorMetadataToolbox extends ChartEditorBaseToolbox\n{/gm => 
    "class ChartEditorMetadataToolbox extends ChartEditorBaseToolbox //Patched 
    {
      public var toolboxNotesCustomKindLabel:Label;
      public var inputDifficultyRating:NumberStepper;
      public var inputTimeSignature:DropDown;

      ",
      ~/class ChartEditorNoteContextMenu extends ChartEditorBaseContextMenu\n{/gm => 
    "class ChartEditorNoteContextMenu extends ChartEditorBaseContextMenu //Patched 
    {
      public var contextmenuAddHold:MenuItem;

      ",   
      ~/class ChartEditorHoldNoteContextMenu extends ChartEditorBaseContextMenu\n{/gm => 
    "class ChartEditorHoldNoteContextMenu extends ChartEditorBaseContextMenu //Patched 
    {
      public var contextmenuRemoveHold:MenuItem;

      ",         
      ~/initializeTicks\(\):Void\s*{[^}]*}/gm => 
    "initializeTicks():Void
  {
    tickTiledSprite = new FlxTiledSprite(chartEditorState.offsetTickBitmap, 100, chartEditorState.offsetTickBitmap.height, true, false);
    // offsetTicksSprite.sprite = tickTiledSprite;
    tickTiledSprite.width = 5000;
  }",   

    ~/class ChartEditorNoteDataToolbox extends ChartEditorBaseToolbox\n{/gm => 
    "class ChartEditorNoteDataToolbox extends ChartEditorBaseToolbox //Patched 
    {
      public var toolboxNotesCustomKindLabel:Label;

      ",
    ~/class ChartEditorFreeplayToolbox extends ChartEditorBaseToolbox\n{/gm => 
    "class ChartEditorFreeplayToolbox extends ChartEditorBaseToolbox //Patched 
    {
      public var testPreview:Button;
      public var freeplayMusicMute:Button;
      public var inputDifficultyRating:NumberStepper;
      public var inputTimeSignature:DropDown;
      public var freeplayMusicVolume:Slider;
      public var freeplayLabelTime:Label;

      ",
    ~/class ChartEditorWelcomeDialog extends ChartEditorBaseDialog\n{/gm => 
    "class ChartEditorWelcomeDialog extends ChartEditorBaseDialog //Patched 
    {
      public var splashCreateFromSongBasicErect:Label;
      public var splashCreateFromSongBasicOnly:Label;
      public var splashCreateFromSongErectOnly:Label;
      public var splashImportChartLegacy:Label;
      public var splashBrowse:Button;

      public var buttonNew:Label;

      public var splashRecentContainer:VBox;
      public var splashTemplateContainer:VBox;

      ",

    ~/class ChartEditorOffsetsToolbox extends ChartEditorBaseToolbox\n{/gm => 
    "class ChartEditorOffsetsToolbox extends ChartEditorBaseToolbox //Patched 
    {
      public var offsetPlayerVolume:Slider;
      public var offsetPlayerMute:Button;
      public var offsetPlayerSolo:Button;

      public var offsetOpponentVolume:Slider;
      public var offsetOpponentMute:Button;
      public var offsetOpponentSolo:Button;

      public var offsetInstrumentalVolume:Slider;
      public var offsetInstrumentalMute:Button;
      public var offsetInstrumentalSolo:Button;

      public var offsetLabelTime:Label;

      ",
      
    ~/class ChartEditorState extends UIState \/\/ UIState derives from MusicBeatState\n{/gm => 
      "class ChartEditorState extends UIState
{
      public var menubarItemToggleToolboxNoteData:MenuCheckBox;
      public var menubarItemToggleToolboxEventData:MenuCheckBox;
      public var menubarItemToggleToolboxOffsets:MenuCheckBox;
      public var menubarItemToggleToolboxOpponentPreview:MenuCheckBox;

      public var menubarItemSelectAllNotes:MenuItem;
      public var menubarItemSelectAllEvents:MenuItem;
      public var menubarItemPlaytestFull:MenuItem;
      public var menubarItemPlaytestMinimal:MenuItem;

      public var menubarItemWelcomeDialog:MenuItem;
      public var menubarItemGoToBackupsFolder:MenuItem;
      public var menubarItemUserGuide:MenuItem;
      public var menubarItemAbout:MenuItem;

      public var menubarItemToggleToolboxDifficulty:MenuCheckBox;
      public var menubarItemToggleToolboxFreeplay:MenuCheckBox;
      public var menubarItemToggleToolboxPlayerPreview:MenuCheckBox;

      public var menubarItemToggleToolboxMetadata:MenuCheckBox;
      public var menubarItemToggleToolboxPlaytestProperties:MenuCheckBox;

      public var playbarDifficulty:Label;
      public var playbarBPM:Label;

      public var menuBarItemThemeDark:CheckBox;
      public var menuBarItemThemeLight:CheckBox;

      public var menuBarItemInputStyleWASD:MenuOptionBox;
      public var menuBarItemInputStyleNumberKeys:MenuOptionBox;
      public var menuBarItemInputStyleNone:MenuOptionBox;
"
  ]; 
}