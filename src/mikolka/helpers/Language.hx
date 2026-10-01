package mikolka.helpers;

class Language {

    public static inline final STARTUP_SETUP_MISSING:String = 
        "Looks like you don't have Funkin Compiler initialised. Would you like to do it now?";    
    public static inline final STARTUP_SETUP_MISSING_TITLE:String = 
        "Startup warning";
    public static inline final STARTUP_SETUP_DIFFERENT_HAXELIB:String = 
        "Looks like you don't have Funkin Compiler's haxelib folder set. Would you like to set it now?";

    public static inline final UTILS_SELECT_WORKSPACE_FOLDER:String = "Select a folder...";

    public static inline final MSG_SETUP_CHECKING_CURL:String = "[SETUP] Checking curl..";
    public static inline final MSG_SETUP_CHECKING_HAXE:String = "[SETUP] Checking haxe..";
    public static inline final SETUP_CURL_ERROR:String = 
        "You don't have 'curl' installed on your system! You need to install it before continuing.";

    public static inline final SETUP_HAXELIB_ERROR_TITLE:String = "Haxelib dependencies folder is not empty!";
    public static inline final SETUP_HAXELIB_ERROR:String = 
        "You seem to have non-empty, or absent haxelib folder.\n" +
        "You can reinstall existing dependencies, or keep them as is.\n" +
        "Do you want to reinstall?";

    public static inline final PROJECT_NAME_PROMPT:String = "Type in the name of the project:";

    public static inline final ACTION_CANCELED:String = "Action canceled!";
    public static inline final ACTION_ABORTED:String = "Action aborted!";
    public static inline final FILE_INPUT_PLACEHOLDER:String = "Enter a path to a file (or use the folder button to pick one)";
    public static inline final DIRECTORY_INPUT_PLACEHOLDER:String = "Enter a path to a directory (or use the folder button to pick one)";
    public static inline final PICK_FILE_BUTTON:String = "Pick a file";
    public static inline final PICK_FOLDER_BUTTON:String = "Pick a folder";

    public static inline final STARTUP_RUNNING_INFO:String = "Funkin IDE is up! If you enjoy using this extension, be sure to share it with others!";

    public static inline final SELECT_FNF_INSTANCE_TO_LAUNCH:String = "Select FNF instance to launch";
    public static inline final PATH_UPDATED_TRY_AGAIN:String = "Path updated! Try launching the game again.";
    public static inline final OPERATION_CANCELLED:String = "Operation cancelled!";
    public static inline final CANNOT_START_GAME_TITLE:String = "Cannot start the game";
    public static inline final CANNOT_START_GAME_DETAIL:String = "You need to open a folder before starting it!";
    public static inline final FNF_FAILED_TO_FUNK:String = "Funkin failed to funk!";

    public static inline final NO_FCPKG_PACKAGE_INSTALLED:String = "No Fcpkg package was installed!";
    public static inline final USE_PREVIOUS:String = "Use previous";
    public static inline final FAILED_TO_SET_HAXELIB_PATH:String = "Failed to set haxelib path!";
    public static inline final RUNNING_FNF_WITHOUT_FOLDER:String = "Running FNF without a folder! This will likely fail!";
    public static inline final SELECT_DIRECTORY_TO_CREATE_PROJECT_IN:String = "Select a directory to create the project in";
    public static inline final FOLDER_NOT_EMPTY_TITLE:String = "Folder not empty";
    public static inline function folderNotEmptyDetail(path:String):String {
        return 'Make sure that ${path} doesn\'t have any files in it.';
    }
    public static inline final DONE:String = "Done!";
    public static inline final FUNKIN_SETUP_COMPLETED_SUCCESSFULLY:String = "Funkin setup completed successfully!";

    public static inline final FNF_MOBILE_ERROR_TITLE:String = "FNF Mobile Error";
    public static inline final FNF_MOBILE_MODS_NOT_ACCESSIBLE:String = "The 'mods' folder of the FNF mobile instance doesn't seem to me accessible. Try running the game or create it!";
    public static inline final FNF_MOBILE_MODS_RECREATED:String = "The 'mods' folder had to be re-created. Existing mods were moved to 'mods-bak'";

    public static inline final FUNKIN_IDE_HAXE_INSTALL_STARTED:String = "Funkin IDE Haxe installation started!";
    public static inline final HAXE_INSTALL_PENDING:String = "There is a pending installation!";
    public static inline final HAXE_INSTALL_UNKNOWN_OS:String = "Unknown OS. Funkin IDE Haxe will not be available!";
    public static inline function failedToDownloadCustomHaxe(reason:String):String {
        return "Failed to download custom Haxe: " + reason;
    }
    public static inline final HAXE_INSTALL_MAKE_EXECUTABLE_FAILED:String = "Failed to make haxe executable!";

    public static inline final VSHAXE_PATCH_PROMPT_TITLE:String = "Funkin Compiler";
    public static inline final VSHAXE_PATCH_PROMPT:String = 
        "Looks like you don't have a patch applied to 'vshaxe language server' yet!\n" +
        "The program will now add support for .hxc files to it.\n\nDo you want to proceed?";

    public static inline function failedToReadMetadata(reason:String):String {
        return "Failed to read metadata for current FcPkg: " + reason;
    }

    public static inline final SELECT_FUNKIN_PACKAGE_TO_USE:String = "Select Funkin package to use";
    public static inline final SELECT_HAXELIB_FOLDER:String = "Select haxelib folder";
    public static inline final SELECT_FCPKG_FILE:String = "Select .fcpkg file";

    public static inline final CPPIA_GENERATING_REFERENCE:String = "Generating export classes for CPPIA";
    public static inline final CPPIA_NOT_SUPPORTED:String = "CPPIA scripting doesn't seem to be supported for this version.";
    public static inline final CPPIA_FAILED_TO_GENERATE:String = "CPPIA couldn't generated an SDK required for compilation.";
}