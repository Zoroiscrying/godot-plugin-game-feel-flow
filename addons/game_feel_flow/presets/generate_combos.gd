@tool
extends EditorScript

## 生成组合效果预设文件
## 在Godot编辑器中运行此脚本生成预设

func _run() -> void:
	_create_combo_presets()
	print("Combo presets created!")

func _create_combo_presets() -> void:
	# 创建预设目录
	var dir = DirAccess.open("res://addons/game_feel_flow/presets/")
	if not dir.dir_exists("combos"):
		dir.make_dir("combos")
	
	# 生成预设文件
	_save_combo("hit_light", GFFCombo.hit_light())
	_save_combo("hit_heavy", GFFCombo.hit_heavy())
	_save_combo("death", GFFCombo.death())
	_save_combo("pickup", GFFCombo.pickup())
	_save_combo("explosion", GFFCombo.explosion())

func _save_combo(name: String, combo: GFFCombo) -> void:
	var path = "res://addons/game_feel_flow/presets/combos/%s.tres" % name
	var error = ResourceSaver.save(combo, path)
	if error == OK:
		print("Saved: ", path)
	else:
		print("Error saving ", path, ": ", error)
