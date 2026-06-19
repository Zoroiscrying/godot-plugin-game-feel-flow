@tool
extends EditorScript

## 生成曲线预设文件
## 在Godot编辑器中运行此脚本生成预设

func _run() -> void:
	_create_curve_presets()
	print("Curve presets created!")

func _create_curve_presets() -> void:
	# 确保目录存在
	var dir = DirAccess.open("res://addons/game_feel_flow/presets/")
	if not dir.dir_exists("curves"):
		dir.make_dir("curves")
	
	# 生成曲线预设
	_save_curve("linear", _create_linear())
	_save_curve("ease_in", _create_ease_in())
	_save_curve("ease_out", _create_ease_out())
	_save_curve("ease_in_out", _create_ease_in_out())
	_save_curve("bounce", _create_bounce())
	_save_curve("elastic", _create_elastic())
	_save_curve("back", _create_back())
	_save_curve("anticipate", _create_anticipate())

func _create_linear() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(1, 1))
	return curve

func _create_ease_in() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(0.42, 0))
	curve.add_point(Vector2(1, 1))
	return curve

func _create_ease_out() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(0.58, 1))
	curve.add_point(Vector2(1, 1))
	return curve

func _create_ease_in_out() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(0.42, 0))
	curve.add_point(Vector2(0.58, 1))
	curve.add_point(Vector2(1, 1))
	return curve

func _create_bounce() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(0.2, 1))
	curve.add_point(Vector2(0.35, 0.7))
	curve.add_point(Vector2(0.5, 1))
	curve.add_point(Vector2(0.65, 0.85))
	curve.add_point(Vector2(0.8, 1))
	curve.add_point(Vector2(0.9, 0.95))
	curve.add_point(Vector2(1, 1))
	return curve

func _create_elastic() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(0.15, 1.2))
	curve.add_point(Vector2(0.3, 0.8))
	curve.add_point(Vector2(0.45, 1.1))
	curve.add_point(Vector2(0.6, 0.95))
	curve.add_point(Vector2(0.75, 1.02))
	curve.add_point(Vector2(0.9, 0.99))
	curve.add_point(Vector2(1, 1))
	return curve

func _create_back() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(0.3, -0.2))
	curve.add_point(Vector2(0.7, 1.2))
	curve.add_point(Vector2(1, 1))
	return curve

func _create_anticipate() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(0.3, -0.1))
	curve.add_point(Vector2(0.7, 0.5))
	curve.add_point(Vector2(1, 1))
	return curve

func _save_curve(name: String, curve: Curve) -> void:
	var path = "res://addons/game_feel_flow/presets/curves/%s.tres" % name
	var error = ResourceSaver.save(curve, path)
	if error == OK:
		print("Saved: ", path)
	else:
		print("Error saving ", path, ": ", error)
