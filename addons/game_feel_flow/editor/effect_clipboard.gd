@tool
extends RefCounted
class_name GFFEffectClipboard

## Static clipboard for copying effect parameters between effects of the same type.

static var _source_script_path: String = ""
static var _data: Dictionary = {}
static var _non_copyable_props := ["script", "Script", "resource_path", "resource_name", "resource_local_to_scene"]


static func copy(effect: GFFEffect) -> void:
	if effect == null:
		return
	var script: Script = effect.get_script()
	_source_script_path = script.get_path() if script else ""
	_data.clear()
	for prop in effect.get_property_list():
		if prop.name in _non_copyable_props:
			continue
		if not (prop.usage & PROPERTY_USAGE_STORAGE):
			continue
		_data[prop.name] = effect.get(prop.name)


static func can_paste(target: GFFEffect) -> bool:
	if target == null or _data.is_empty():
		return false
	var script: Script = target.get_script()
	var target_path: String = script.get_path() if script else ""
	return target_path == _source_script_path


static func paste(target: GFFEffect) -> bool:
	if not can_paste(target):
		return false
	for key in _data:
		if key in target:
			target.set(key, _data[key])
	return true
