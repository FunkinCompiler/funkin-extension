package mikolka.helpers;

class LangStrings {

    // Prompts
    public static inline final MSG_EXPORT_ZIP_NAME:String = 
		"Type in a name for your exported file (without .zip):";
	public static inline final MSG_EXPORT_META_MISSING:String = 
		"Your mod doesn't contain \"_polymod_meta.json\". Please create a valid metadata file for this mod first!";
	public static inline final MSG_EXPORT_META_NO_VERSION:String = 
		'It seems like your "_polymod_meta.json" is missing a "mod_version" attribute...';
	public static inline final MSG_EXPORT_MOD_VERSION:String = "What version number should be used for this mod version? Leave blank to use the current one";

    public static inline final MSG_SETUP_CHECKING_GIT:String = "[SETUP] Checking git..";
    public static inline final MSG_SETUP_CHECKING_HAXE:String = "[SETUP] Checking haxe..";
    public static inline final SETUP_GIT_ERROR:String = 
    "Git is absent on this system. You can install it from here: https://git-scm.com/";
    public static inline final SETUP_HAXE_ERROR:String = 
    "You don't have haxe???\nGet it from here: https://haxe.org/download/";
    public static inline final SETUP_HAXELIB_ERROR:String = 
    "You seem to have non-empty, or absent dependencies folder.\n"+
    "You can reinstall existing dependencies, or keep them as is.\n"+
    "Do you want to reinstall? (yes/no): ";
    // Project
	public static inline final PROJECT_NAME_PROMPT:String = "Type in the name of the project:";

    //FNFC
    public static inline function FNFC_INVALID_FILE(file_path:String) {
        return '[WARN] $file_path is not a valid chart file. Ignoring!';
    }
    public static inline function FNFC_INVALID_MANIFEST(file_path:String) {
        return 'File $file_path doesn\'t contain a valid "manifest.json" file';
    }
    public static inline function FNFC_INVALID_MANIFEST_SONG_ID(file_path:String) {
        return 'It seems like "manifest.json" in $file_path is missing a "songId" attribute...';
    }
}