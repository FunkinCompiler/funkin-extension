package mikolka;

import funkin.modding.module.Module;
import haxe.PosInfos;
import haxe.Log;
import funkin.Assets;
import haxe.ds.StringMap;
import haxe.io.BytesBuffer;
import haxe.Exception;
import funkin.modding.ModStore;
import haxe.Json;
import flixel.FlxG;
import funkin.util.ReflectUtil;
import funkin.util.plugins.ReloadAssetsDebugPlugin;
import funkin.modding.events.ScriptEvent;
import openfl.net.Socket;

using StringTools;

/**
 * This is example module showing how to manipulate game's states
 */
class FunkServer extends Module {
	var reference:Socket;
	var reload:ReloadAssetsDebugPlugin;
	var sockBuf:BytesBuffer;

	var test = 10;

	public function new() {
		super("funkin-compiler-socket", 1000);
		sockBuf = new BytesBuffer();
		reload = new ReloadAssetsDebugPlugin();
	}

	override function onCreate(event:ScriptEvent) {
		reference = ModStore.register("funkin-compiler-socket", new Socket());
		FlxG.plugins.removeAllByType(ReloadAssetsDebugPlugin);
		var ipTarget:String = "127.0.0.1";

		if (FlxG.onMobile) {
			ipTarget = Assets.getText("server.txt").replace("\n", "");
			Log.trace = traceToSocket;
		}
		if (!reference.connected)
			reference.connect(ipTarget, 3004);
		super.onCreate(event);
	}

	override function onUpdate(event:UpdateScriptEvent) {
		if (reference.bytesAvailable > 0) {
			var seq = reference.readUTF();
			var payload = Json.parse(seq);
			onEventCapture(payload.event, payload.params, payload.id);
		}
		if (FlxG.keys.justPressed.F5) {
			sendEvent("ingame-reload", [], -1);
			reload.reload();
		}
	}

	function onEventCapture(event:String, values:Array<String>, id:Int) {
		if (event == "restart") {
			reload.reload();
		} else if (event == "execute") {
			if (values.length == 0) {
				sendEvent("execute_resp", ["true", "No command given!"], id);
				return;
			}
			try {
				var seq_code_blocks:Array<Dynamic> = Json.parse(values[0]);
				// trace(seq_code_blocks);
				var result = ExecuteCommandCall(seq_code_blocks);
				sendEvent("execute_resp", [result.isError, result.msg], id);
			} catch (x:Exception) {
				trace(x.message);
				sendEvent("execute_resp", ["true", "Exception occurred!"], id);
			}
		} else if (event == "list_variables") {
			if (values.length == 0) {
				sendEvent("list_variables_resp", ["true", "No command given!"], id);
				return;
			}
			try {
				var seq_code_blocks:Array<Dynamic> = Json.parse(values[0]);
				// trace(seq_code_blocks);
				var result = getFieldsByCmd(seq_code_blocks);
				sendEvent("list_variables_resp", ["false", Json.stringify(result)], id);
			} catch (x:Exception) {
				trace(x.message);
				sendEvent("list_variables_resp", ["true", "Exception occurred!"], id);
			}
		}
	}

	function sendEvent(event:String, values:Array<String>, id:Int) {
		if (!reference.connected)
			return;
		var payload = {
			"event": event,
			"params": values,
			"id": id
		};
		// trace(payload);
		reference.writeUTF(Json.stringify(payload));
		reference.flush();
	}

	function traceToSocket(v:Dynamic, ?infos:PosInfos):Void {
		if (!reference.connected)
			return;
		sendEvent("trace", [Log.formatOutput(v, infos)], -1);
	}

	function getRet(obj:Dynamic, fuzzyName:String) {
		var completions = [];
		var fuzzyFieldLength = fuzzyName.length;
		var mpLookup = null;
		var mpGetter = null;

		if (Std.isOfType(obj, StringMap)) {
			var strArray = obj;
			mpLookup = strArray.keys();
			mpGetter = (varName:String) -> strArray.get(varName);
		} else {
			var strArray = ReflectUtil.getInstanceFieldsOf(obj);
			mpLookup = strArray.iterator();
			mpGetter = (varName:String) -> {
				try {
					return ReflectUtil.getProperty(obj, varName);
				} catch (X:Exception) {
					return null;
				}
			}
			if (strArray.length == 0) {
				mpLookup = ReflectUtil.getFieldsOf(obj).iterator();
				mpGetter = (varName:String) -> getObjField(obj, varName);
			}
		}

		for (fieldName in mpLookup) {
			if (fuzzyName != "" && fieldName.toLowerCase().startsWith(fuzzyName.toLowerCase()))
				continue;
			var value = mpGetter(fieldName);
			if(value == null){
				completions.push({
					field: fieldName,
					field_type: "text"
				});
			}
			else{
				completions.push({
					field: fieldName,
					field_type: ReflectUtil.isFunction(value) ? "method" : "field"
				});
			}
		}
		return {
			"completions": completions,
			"fuzzyFieldLength": fuzzyFieldLength
		}
	}

	function getFieldsByCmd(values:Array<Dynamic>):Dynamic {
		var leftObj:Dynamic = null;
		var inspectedVarName = "";
		// val.type | val.value
		for (val in values) {
			switch (val.type) {
				case "Var":
					{
						if (inspectedVarName != "") {
							if (leftObj == null) {
								var newModule = ModStore.get(inspectedVarName);
								if (newModule == null)
									return [];
								leftObj = newModule;
							} else {
								leftObj = getObjField(leftObj, inspectedVarName);
								if(leftObj == null) return {"isError": "true", "msg": inspectedVarName+" appears to be blacklisted!"};
							}
						}
						inspectedVarName = val.value;
					}
				case "None":
					{
						switch (val.value) {
							case ".": {
									if (leftObj == null) {
										var newModule = ModStore.get(inspectedVarName);
										if (newModule == null)
											return [];
										leftObj = newModule;
									} else {
										leftObj = getObjField(leftObj, inspectedVarName);
										if(leftObj == null) return {"isError": "true", "msg": inspectedVarName+" appears to be blacklisted!"};
									}
									inspectedVarName = "";
								}
						}
					}
			}
		}
		if (leftObj == null)
			return getRet(ModStore.stores, inspectedVarName);
		return getRet(leftObj, inspectedVarName);
	}

	function ExecuteCommandCall(values:Array<Dynamic>):Dynamic {
		var leftObj:Dynamic = null;
		var assign_target = null;
		var method_args:Array<Dynamic> = null;
		// val.type | val.value
		for (val in values) {
			switch (val.type) {
				case "Var":
					{
						if (assign_target != null)
							return {"isError": "true", "msg": "Invalid syntax (in Var)"}
						if (leftObj == null) {
							var newModule = ModStore.get(val.value);
							if (newModule == null)
								return {"isError": "true", "msg": "Store not found!"}
							leftObj = newModule;
						} else {
							leftObj = getObjField(leftObj, val.value);
							if(leftObj == null) return {"isError": "true", "msg": val.value+" appears to be blacklisted!"};
						}
					}
				case "Ass":
					{
						if (assign_target != null)
							return {"isError": "true", "msg": "Invalid syntax (in assign)"}
						assign_target = val.value;
					}
				case "Value":
					{
						var set_value = Json.parse(val.value);
						if (assign_target != null) {
							if (leftObj == null) {
								ModStore.stores.remove(assign_target);
								ModStore.stores.set(assign_target, set_value);
								return {"isError": "false", "msg": set_value}
							} else {
								ReflectUtil.setField(leftObj, assign_target, set_value);
								return {"isError": "false", "msg": ""}
							}
						} else if (method_args != null) {
							method_args.push(set_value);
						} else {
							return {"isError": "false", "msg": ReflectUtil.getClassNameOf(set_value)}
						}
					}
				case "Exec":
					{
						leftObj = getObjField(leftObj, val.value);
						if(leftObj == null) return {"isError": "true", "msg": "Trying to execute null. Is this field blacklisted???"};
						method_args = [];
					}
				case "Special":
					{
						switch (val.value) {
							case ")": {
									var ret_value = null;
									try {
										switch (method_args.length) {
											case 0: ret_value = leftObj();
											case 1: ret_value = leftObj(method_args[0]);
											case 2: ret_value = leftObj(method_args[0], method_args[1]);
											default: ret_value = leftObj(method_args[0], method_args[1], method_args[2]);
										}
										return {"isError": "false", "msg": Json.stringify(ret_value)};
									} catch (x:Exception) {
										return {"isError": "true", "msg": x.message};
									}
								}
						}
					}
			}
			if (leftObj != null) {
				try {
					return {
						"isError": "false",
						msg: Json.stringify(leftObj),
					}
				} catch (x:Exception) {
					try {
						return {
							"isError": "false",
							msg: Json.stringify(ReflectUtil.getAnonymousFieldsOf(leftObj)),
						}
					} catch (x:Exception) {
						return {"isError": "true", "msg": "Unparsable value! " + x.message};
					}
				}
			}
			return {"isError": "true", "msg": "Incomplete command / Value is null"};
		}
		return {"isError": "false", "msg": "Operation completed!"};
	}

	function getObjField(obj:Any, name:String):Dynamic {
		try {
			return ReflectUtil.getField(obj, name);
		} catch (X:Exception) {
			return null;
		}
	}
}
