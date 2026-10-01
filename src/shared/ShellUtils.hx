package shared;

import haxe.Rest;
import haxe.extern.EitherType;
#if js
import js.Syntax;
#end

class ShellUtils {
	/**
		Escaped this string to prevent spaces being interpreted as separate arguments.
		
		Useful for shell commands/arguments.
	**/
	public inline static function shellPath(value:String) {
		return '"$value"';
	}

	public static function isNull(value:Dynamic):Bool{
		return value == null || value == js.Lib.undefined;
	}
	public static function isEmpty(value:String):Bool{
		return value == null || value == js.Lib.undefined || value == "";
	}
	/**
		Enumerate every element in an array. 
	**/
	public inline static function forEach<T>(root:EitherType<Rest<T>,Array<T>>,callback:T->Void) {
		#if js
		Syntax.code("{0}.forEach({1})",root,callback);
		#else
		for(x in root){
			callback(x);
		}
		#end
	}
	public inline static function mapInto<A,B>(root:Array<A>,callback:A->B):Array<B> {
		#if js
		return Syntax.code("{0}.map({1})",root,callback);
		#else
		return root.map(callback);
		#end
	}
	public inline static function filterInto<A,B>(root:Array<A>,callback:A->Bool):Array<A> {
		#if js
		return Syntax.code("{0}.filter({1})",root,callback);
		#else
		return root.filter(callback);
		#end
	}
}