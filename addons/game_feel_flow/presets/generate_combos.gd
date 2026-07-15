@tool
extends SceneTree

## Optional tool: export any GFFCombo as a .tres preset file in the project
## Built-in Combos are still provided at runtime by GFFCombo static factories; no need and should not pre-export.
## Usage example:
##   godot --headless --path . --script res://addons/game_feel_flow/presets/generate_combos.gd

func _initialize() -> void:
	# Default example: export a few common built-in Combos to the project directory (demo only; modify list as needed)
	var combos: Array[Array] = [
		["hit_light", GFFCombo.hit_light()],
	]
	_export_combos(combos)
	print("Combo presets exported!")
	quit()

func _export_combos(combos: Array[Array]) -> void:
	# Create preset directory
	var dir = DirAccess.open("res://addons/game_feel_flow/presets/")
	if not dir.dir_exists("combos"):
		dir.make_dir("combos")

	for item in combos:
		_save_combo(item[0], item[1])

func _save_combo(name: String, combo: GFFCombo) -> void:
	var path = "res://addons/game_feel_flow/presets/combos/%s.tres" % name
	var error = ResourceSaver.save(combo, path)
	if error == OK:
		print("Saved: ", path)
	else:
		print("Error saving ", path, ": ", error)
