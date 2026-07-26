class_name GFFProjectSettings
extends RefCounted

## Game Feel Flow project settings (Project → Project Settings → Game Feel Flow).

const SEARCH_PATHS_SETTING := "game_feel_flow/combos/search_paths"
const SAVE_PATH_SETTING := "game_feel_flow/combos/save_path"

## Default directories scanned for project combo `.tres` files.
const DEFAULT_SEARCH_PATHS := [
	"res://presets/combos/",
	"res://effects/combos/",
]
const DEFAULT_SAVE_PATH := "res://presets/combos/"


static func ensure_registered() -> void:
	## Register settings so they appear in Project Settings. Safe to call repeatedly.
	if not ProjectSettings.has_setting(SEARCH_PATHS_SETTING):
		ProjectSettings.set_setting(SEARCH_PATHS_SETTING, DEFAULT_SEARCH_PATHS.duplicate())
	ProjectSettings.set_initial_value(SEARCH_PATHS_SETTING, DEFAULT_SEARCH_PATHS.duplicate())
	ProjectSettings.add_property_info({
		"name": SEARCH_PATHS_SETTING,
		"type": TYPE_ARRAY,
		"hint": PROPERTY_HINT_TYPE_STRING,
		"hint_string": "%d/%d:" % [TYPE_STRING, PROPERTY_HINT_DIR],
	})
	ProjectSettings.set_as_basic(SEARCH_PATHS_SETTING, true)

	if not ProjectSettings.has_setting(SAVE_PATH_SETTING):
		ProjectSettings.set_setting(SAVE_PATH_SETTING, DEFAULT_SAVE_PATH)
	ProjectSettings.set_initial_value(SAVE_PATH_SETTING, DEFAULT_SAVE_PATH)
	ProjectSettings.add_property_info({
		"name": SAVE_PATH_SETTING,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_DIR,
	})
	ProjectSettings.set_as_basic(SAVE_PATH_SETTING, true)


static func get_combo_search_paths() -> Array[String]:
	## Directories scanned for project combo `.tres` files (global play + Browser).
	ensure_registered()
	var value: Variant = ProjectSettings.get_setting(SEARCH_PATHS_SETTING, DEFAULT_SEARCH_PATHS)
	var paths: Array[String] = []
	if value is PackedStringArray:
		for p in value:
			var normalized := _normalize_dir(str(p))
			if not normalized.is_empty() and normalized not in paths:
				paths.append(normalized)
	elif value is Array:
		for p in value:
			var normalized := _normalize_dir(str(p))
			if not normalized.is_empty() and normalized not in paths:
				paths.append(normalized)
	if paths.is_empty():
		for p in DEFAULT_SEARCH_PATHS:
			paths.append(_normalize_dir(str(p)))
	return paths


static func get_combo_save_path() -> String:
	## Directory used by "Save as Project Combo".
	ensure_registered()
	var value := str(ProjectSettings.get_setting(SAVE_PATH_SETTING, DEFAULT_SAVE_PATH))
	var path := _normalize_dir(value)
	if path.is_empty():
		var search := get_combo_search_paths()
		return search[0] if not search.is_empty() else DEFAULT_SAVE_PATH
	return path


static func save_combo(combo: GFFCombo, preferred_name: String = "", overwrite: bool = true) -> String:
	## Save `combo` under Project Settings save_path. Returns the written path, or "" on failure.
	if combo == null:
		return ""
	var dir_path := get_combo_save_path()
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)

	var base_name := preferred_name.strip_edges()
	if base_name.is_empty():
		base_name = combo.label.strip_edges()
	if base_name.is_empty():
		base_name = "combo"
	base_name = base_name.validate_filename()
	if base_name.is_empty():
		base_name = "combo"

	if combo.label.is_empty():
		combo.label = base_name

	var path := dir_path + base_name + ".tres"
	if not overwrite:
		var index := 1
		while FileAccess.file_exists(path):
			path = dir_path + base_name + "_" + str(index) + ".tres"
			index += 1

	var err := ResourceSaver.save(combo, path)
	if err != OK:
		push_error("GFFProjectSettings: Failed to save combo to %s (%s)" % [path, error_string(err)])
		return ""
	return path


static func _normalize_dir(path: String) -> String:
	var cleaned := path.strip_edges().replace("\\", "/")
	if cleaned.is_empty():
		return ""
	if not cleaned.ends_with("/"):
		cleaned += "/"
	return cleaned
