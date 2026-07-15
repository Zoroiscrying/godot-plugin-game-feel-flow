@tool
extends SceneTree

## Generate curve preset files
## Can be run via Godot CLI: godot --headless --path . --script res://addons/game_feel_flow/presets/generate_curves.gd

func _initialize() -> void:
	_create_curve_presets()
	print("Curve presets created!")
	quit()

func _create_curve_presets() -> void:
	# Ensure directory exists
	var dir = DirAccess.open("res://addons/game_feel_flow/presets/")
	if not dir.dir_exists("curves"):
		dir.make_dir("curves")

	# Basic linear
	_save_curve("linear", _create_linear())

	# Ease In series
	_save_curve("ease_in", _create_ease_in())
	_save_curve("ease_in_quad", _create_ease_in_quad())
	_save_curve("ease_in_cubic", _create_ease_in_cubic())

	# Ease Out series
	_save_curve("ease_out", _create_ease_out())
	_save_curve("ease_out_quad", _create_ease_out_quad())
	_save_curve("ease_out_cubic", _create_ease_out_cubic())

	# Ease In-Out series
	_save_curve("ease_in_out", _create_ease_in_out())
	_save_curve("ease_in_out_quad", _create_ease_in_out_quad())

	# Special effects
	_save_curve("bounce", _create_bounce())
	_save_curve("elastic", _create_elastic())
	_save_curve("back", _create_back())
	_save_curve("snap", _create_snap())
	_save_curve("smooth_step", _create_smooth_step())

	# Decay curve
	_save_curve("decay_linear", _create_decay_linear())
	_save_curve("decay_ease_out", _create_decay_ease_out())

	# Shake curve
	_save_curve("shake_sine", _create_shake_sine())

	# Anticipation
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

func _create_ease_in_quad() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(0.55, 0.085))
	curve.add_point(Vector2(0.68, 0.22))
	curve.add_point(Vector2(0.77, 0.43))
	curve.add_point(Vector2(0.87, 0.69))
	curve.add_point(Vector2(1, 1))
	return curve

func _create_ease_in_cubic() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(0.65, 0.05))
	curve.add_point(Vector2(0.8, 0.2))
	curve.add_point(Vector2(0.9, 0.5))
	curve.add_point(Vector2(1, 1))
	return curve

func _create_ease_out() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(0.58, 1))
	curve.add_point(Vector2(1, 1))
	return curve

func _create_ease_out_quad() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(0.13, 0.31))
	curve.add_point(Vector2(0.23, 0.57))
	curve.add_point(Vector2(0.32, 0.78))
	curve.add_point(Vector2(0.45, 0.915))
	curve.add_point(Vector2(1, 1))
	return curve

func _create_ease_out_cubic() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(0.1, 0.5))
	curve.add_point(Vector2(0.2, 0.8))
	curve.add_point(Vector2(0.35, 0.95))
	curve.add_point(Vector2(1, 1))
	return curve

func _create_ease_in_out() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(0.42, 0))
	curve.add_point(Vector2(0.58, 1))
	curve.add_point(Vector2(1, 1))
	return curve

func _create_ease_in_out_quad() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(0.25, 0.05))
	curve.add_point(Vector2(0.5, 0.5))
	curve.add_point(Vector2(0.75, 0.95))
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

func _create_snap() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(0.8, 0))
	curve.add_point(Vector2(0.9, 1.2))
	curve.add_point(Vector2(1, 1))
	return curve

func _create_smooth_step() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(0.2, 0.05))
	curve.add_point(Vector2(0.4, 0.25))
	curve.add_point(Vector2(0.6, 0.75))
	curve.add_point(Vector2(0.8, 0.95))
	curve.add_point(Vector2(1, 1))
	return curve

func _create_decay_linear() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0, 1))
	curve.add_point(Vector2(1, 0))
	return curve

func _create_decay_ease_out() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0, 1))
	curve.add_point(Vector2(0.3, 0.7))
	curve.add_point(Vector2(0.6, 0.35))
	curve.add_point(Vector2(1, 0))
	return curve

func _create_shake_sine() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0, 1))
	curve.add_point(Vector2(0.25, -0.6))
	curve.add_point(Vector2(0.5, 0.3))
	curve.add_point(Vector2(0.75, -0.15))
	curve.add_point(Vector2(1, 0))
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
