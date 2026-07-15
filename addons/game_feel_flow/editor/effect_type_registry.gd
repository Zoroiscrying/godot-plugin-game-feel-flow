@tool
extends RefCounted
class_name GFFEffectTypeRegistry

## Central registry for effect type scripts under addons/game_feel_flow/effects.

const EFFECTS_DIR := "res://addons/game_feel_flow/effects"
const EXCLUDED_NAMES := []


static func get_effect_types() -> Array[Dictionary]:
	## Returns an array of {name, path} dictionaries for every concrete effect.
	var result: Array[Dictionary] = []
	_scan_dir(EFFECTS_DIR, result)
	result.sort_custom(_sort_types)
	return result


static func _scan_dir(path: String, out: Array[Dictionary]) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		var full_path := path.path_join(file_name)
		if dir.current_is_dir():
			_scan_dir(full_path, out)
		elif file_name.begins_with("gff_") and file_name.ends_with(".gd"):
			var base_name := file_name.get_basename()
			if base_name not in EXCLUDED_NAMES:
				var display := base_name.replace("gff_", "").replace("_", " ").capitalize()
				out.append({"name": display, "path": full_path})
		file_name = dir.get_next()
	dir.list_dir_end()


static func _sort_types(a: Dictionary, b: Dictionary) -> bool:
	var cat_a := _category_index(a.path)
	var cat_b := _category_index(b.path)
	if cat_a != cat_b:
		return cat_a < cat_b
	return a.name < b.name


static func _category_index(path: String) -> int:
	if "/visual/" in path: return 0
	if "/transform/" in path: return 1
	if "/camera/" in path: return 2
	if "/audio/" in path: return 3
	if "/time/" in path: return 4
	if "/particles/" in path: return 5
	if "/ui/" in path: return 6
	if "/events/" in path: return 7
	if "/physics/" in path: return 8
	if "/animation/" in path: return 9
	return 99
