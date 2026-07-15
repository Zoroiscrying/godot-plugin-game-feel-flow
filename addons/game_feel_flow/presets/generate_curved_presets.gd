@tool
extends EditorScript

## Generate common effect preset files

func _run() -> void:
	_create_curved_presets()
	print("Common effect presets created!")

func _create_curved_presets() -> void:
	_save_preset("shake_position", _create_shake_position())
	_save_preset("shake_scale", _create_shake_scale())
	_save_preset("shake_rotation", _create_shake_rotation())
	_save_preset("punch_position", _create_punch_position())
	_save_preset("punch_scale", _create_punch_scale())
	_save_preset("punch_rotation", _create_punch_rotation())
	_save_preset("curved_position", _create_curved_position())
	_save_preset("curved_scale", _create_curved_scale())
	_save_preset("curved_rotation", _create_curved_rotation())

func _create_shake_position() -> GFFEffectCommon:
	var effect := GFFEffectCommon.new()
	effect.target = GFFPositionTarget.new()
	effect.tweener = GFFShakeTweener.new()
	effect.tweener.amplitude = 0.5
	effect.duration = 0.3
	return effect

func _create_shake_scale() -> GFFEffectCommon:
	var effect := GFFEffectCommon.new()
	effect.target = GFFScaleTarget.new()
	effect.tweener = GFFShakeTweener.new()
	effect.tweener.amplitude = 0.2
	effect.duration = 0.3
	return effect

func _create_shake_rotation() -> GFFEffectCommon:
	var effect := GFFEffectCommon.new()
	effect.target = GFFRotationTarget.new()
	effect.tweener = GFFShakeTweener.new()
	effect.tweener.amplitude = 10.0
	effect.duration = 0.3
	return effect

func _create_punch_position() -> GFFEffectCommon:
	var effect := GFFEffectCommon.new()
	effect.target = GFFPositionTarget.new()
	effect.target.target_value = Vector3(10.0, 0.0, 0.0)
	effect.tweener = GFFElasticTweener.new()
	effect.duration = 0.4
	return effect

func _create_punch_scale() -> GFFEffectCommon:
	var effect := GFFEffectCommon.new()
	effect.target = GFFScaleTarget.new()
	effect.target.target_value = Vector3(1.3, 1.3, 1.0)
	effect.tweener = GFFElasticTweener.new()
	effect.tweener.punch_mode = GFFElasticTweener.PunchMode.TO_ORIGIN
	effect.duration = 0.4
	return effect

func _create_punch_rotation() -> GFFEffectCommon:
	var effect := GFFEffectCommon.new()
	effect.target = GFFRotationTarget.new()
	effect.target.target_value = 15.0
	effect.tweener = GFFElasticTweener.new()
	effect.tweener.punch_mode = GFFElasticTweener.PunchMode.TO_ORIGIN
	effect.duration = 0.4
	return effect

func _create_curved_position() -> GFFEffectCommon:
	var effect := GFFEffectCommon.new()
	effect.target = GFFPositionTarget.new()
	effect.target.target_value = Vector3(10.0, 0.0, 0.0)
	effect.tweener = GFFLinearTweener.new()
	effect.duration = 0.5
	return effect

func _create_curved_scale() -> GFFEffectCommon:
	var effect := GFFEffectCommon.new()
	effect.target = GFFScaleTarget.new()
	effect.target.target_value = Vector3(1.2, 1.2, 1.0)
	effect.tweener = GFFLinearTweener.new()
	effect.duration = 0.5
	return effect

func _create_curved_rotation() -> GFFEffectCommon:
	var effect := GFFEffectCommon.new()
	effect.target = GFFRotationTarget.new()
	effect.target.target_value = 15.0
	effect.tweener = GFFLinearTweener.new()
	effect.duration = 0.5
	return effect

func _save_preset(name: String, effect: GFFEffectCommon) -> void:
	var path = "res://addons/game_feel_flow/presets/effects/curved/%s.tres" % name
	var error = ResourceSaver.save(effect, path)
	if error == OK:
		print("Saved: ", path)
	else:
		print("Error saving ", path, ": ", error)
