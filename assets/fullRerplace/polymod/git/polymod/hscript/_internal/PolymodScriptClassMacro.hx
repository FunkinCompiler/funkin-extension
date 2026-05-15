package polymod.hscript._internal;

using StringTools;
import haxe.ds.StringMap;
import haxe.ds.IntMap;
import haxe.io.Bytes;

typedef AbstractImplEntry = {
  cls:Class<Dynamic>,
  polymodCls:Null<Class<Dynamic>>
}

class PolymodScriptClassMacro
{
  static inline final METADATA_RESOURCE_NAME:String = 'PolymodScriptClassMacro_METADATA';

  // Dummy flags (kept for API compatibility; macros not used here)
  static var onGenerateCallbackRegistered:Bool = false;
  static var onAfterTypingCallbackRegistered:Bool = false;

  // ---- Public API (non-macro stubs) ----
  public static function listHScriptedClasses():Map<String, Class<Dynamic>>
  {
    // Return an empty map in the dummy implementation
    return new StringMap<Class<Dynamic>>();
  }

  public static function listAbstractImpls():Map<String, AbstractImplEntry>
  {
    return new StringMap<AbstractImplEntry>();
  }

  public static function listTypedefs():Map<String, Class<Dynamic>>
  {
    return new StringMap<Class<Dynamic>>();
  }

  // ---- Fetch helpers used by the real implementation ----
  static var _metadata:Dynamic = null;

  public static function fetchHScriptedClasses():Map<String, Class<Dynamic>>
  {
    // A simple safe fallback: return empty map
    return new StringMap<Class<Dynamic>>();
  }

  public static function fetchAbstractImpls():Map<String, AbstractImplEntry>
  {
    return new StringMap<AbstractImplEntry>();
  }

  public static function fetchTypedefs():Map<String, Class<Dynamic>>
  {
    return new StringMap<Class<Dynamic>>();
  }

  static function fetchMetadata():Dynamic
  {
    if (_metadata != null) return _metadata;

    // Try to load resource; if missing, return an empty anonymous object
    try {
      var metaDataHXSF:String = haxe.Resource.getString(METADATA_RESOURCE_NAME);
      // In the real implementation this would be unserialized into a structure.
      // Here we attempt to unserialize but fall back gracefully.
      try {
        _metadata = haxe.Unserializer.run(metaDataHXSF);
      } catch (e:Dynamic) {
        _metadata = { hscriptedClasses: null, abstractImpls: null, typedefs: null };
      }
    } catch (e:Dynamic) {
      _metadata = { hscriptedClasses: null, abstractImpls: null, typedefs: null };
    }

    return _metadata;
  }
}
