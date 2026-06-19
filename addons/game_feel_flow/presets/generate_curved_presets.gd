@tool
extends EditorScript

## 生成曲线效果预设文件
## 在Godot编辑器中运行此脚本生成预设

func _run() -> void:
	_create_curved_presets()
	print("Curved presets created!")

func _create_curved_presets() -> void:
	# Shake预设
	_save_preset("shake_position", _create_shake_position())
	_save_preset("shake_scale", _create_shake_scale())
	_save_preset("shake_rotation", _create_shake_rotation())
	
	# Punch预设
	_save_preset("punch_position", _create_punch_position())
	_save_preset("punch_scale", _create_punch_scale())
	_save_preset("punch_rotation", _create_punch_rotation())
	
	# Curved预设
	_save_preset("curved_position", _create_curved_position())
	_save_preset("curved_scale", _create_curved_scale())
	_save_preset("curved_rotation", _create_curved_rotation())

func _create_shake_position() -> GFFCurvedBase:
	var effect = GFFCurvedBase.new()
	effect.target_type = GFFCurvedBase.TargetType.POSITION
	effect.tweener_type = GFFCurvedBase.TweenerType.SHAKE
	effect.amplitude = 0.5
	effect.duration = 0.3
	return effect

func _create_shake_scale() -> GFFCurvedBase:
	var effect = GFFCurvedBase.new()
	effect.target_type = GFFCurvedBase.TargetType.SCALE
	effect.tweener_type = GFFCurvedBase.TweenerType.SHAKE
	effect.amplitude = 0.2
	effect.duration = 0.3
	return effect

func _create_shake_rotation() -> GFFCurvedBase:
	var effect = GFFCurvedBase.new()
	effect.target_type = GFFCurvedBase.TargetType.ROTATION
	effect.tweener_type = GFFCurvedBase.TweenerType.SHAKE
	effect.amplitude = 10.0
	effect.duration = 0.3
	return effect

func _create_punch_position() -> GFFCurvedBase:
	var effect = GFFCurvedBase.new()
	effect.target_type = GFFCurvedBase.TargetType.POSITION
	effect.tweener_type = GFFCurvedBase.TweenerType.ELASTIC
	effect.target_value = Vector2(10.0, 0.0)
	effect.elasticity = 0.5
	effect.duration = 0.4
	return effect

func _create_punch_scale() -> GFFCurvedBase:
	var effect = GFFCurvedBase.new()
	effect.target_type = GFFCurvedBase.TargetType.SCALE
	effect.tweener_type = GFFCurvedBase.TweenerType.ELASTIC
	effect.target_value = Vector2(1.3, 1.3)
	effect.elasticity = 0.5
	effect.duration = 0.4
	return effect

func _create_punch_rotation() -> GFFCurvedBase:
	var effect = GFFCurvedBase.new()
	effect.target_type = GFFCurvedBase.TargetType.ROTATION
	effect.tweener_type = GFFCurvedBase.TweenerType.ELASTIC
	effect.target_angle = 15.0
	effect.elasticity = 0.5
	effect.duration = 0.4
	return effect

func _create_curved_position() -> GFFCurvedBase:
	var effect = GFFCurvedBase.new()
	effect.target_type = GFFCurvedBase.TargetType.POSITION
	effect.tweener_type = GFFCurvedBase.TweenerType.LINEAR
	effect.target_value = Vector2(10.0, 0.0)
	effect.duration = 0.5
	return effect

func _create_curved_scale() -> GFFCurvedBase:
	var effect = GFFCurvedBase.new()
	effect.target_type = GFFCurvedBase.TargetType.SCALE
	effect.tweener_type = GFFCurvedBase.TweenerType.LINEAR
	effect.target_value = Vector2(1.2, 1.2)
	effect.duration = 0.5
	return effect

func _create_curved_rotation() -> GFFCurvedBase:
	var effect = GFFCurvedBase.new()
	effect.target_type = GFFCurvedBase.TargetType.ROTATION
	effect.tweener_type = GFFCurvedBase.TweenerType.LINEAR
	effect.target_angle = 15.0
	effect.duration = 0.5
	return effect

func _save_preset(name: String, effect: GFFCurvedBase) -> void:
	var path = "res://addons/game_feel_flow/presets/effects/curved/%s.tres" % name
	var error = ResourceSaver.save(effect, path)
	if error == OK:
		print("Saved: ", path)
	else:
		print("Error saving ", path, ": ", error)
