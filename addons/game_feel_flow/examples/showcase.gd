extends Control

## Free showcase reel. Prev/Next change shots manually; Replay restarts;
## H hides chrome. No auto-advance.
##
## Subject is a Kenney Generic Items prop (CC0). Same effects also work on 3D.

const SUBJECT_TEXTURE := preload("res://addons/game_feel_flow/examples/assets/sprites/kenney_prop.png")

@onready var stage: Control = $Stage
@onready var subject: Node2D = $SubjectLayer/Subject
@onready var subject_sprite: Sprite2D = $SubjectLayer/Subject/Sprite
@onready var controller: GFFShowcaseController = $ShowcaseController
@onready var chrome = $CanvasLayer/ShowcaseChrome
@onready var sine_mover: GFFShowcaseSineMover = $SineMover

var _loop_timer: Timer
var _subject_default_position: Vector2
var _shot_token: int = 0


func _ready() -> void:
	if subject_sprite and SUBJECT_TEXTURE:
		subject_sprite.texture = SUBJECT_TEXTURE
		var target_h := 220.0
		if subject_sprite.texture.get_height() > 0:
			subject_sprite.scale = Vector2.ONE * (target_h / float(subject_sprite.texture.get_height()))

	_subject_default_position = subject.position
	stage.resized.connect(_center_subject)
	_center_subject()

	sine_mover.target_path = subject.get_path()
	chrome.bind_controller(controller)

	_loop_timer = Timer.new()
	_loop_timer.one_shot = true
	add_child(_loop_timer)
	_loop_timer.timeout.connect(_on_loop_timeout)

	controller.set_shots([
		_shot("impact", "Impact — hit_light", _start_impact, _stop_shot),
		_shot("hit_combo", "Hit Combo — hit_heavy", _start_hit_combo, _stop_shot),
		_shot("shake", "Shake — position tremor", _start_shake, _stop_shot),
		_shot("flash", "Flash — white blink", _start_flash, _stop_shot),
		_shot("punch", "Punch — elastic scale", _start_punch, _stop_shot),
		_shot("motion", "Motion — hop position", _start_motion, _stop_shot),
		_shot("color", "Color — tint pulse", _start_color, _stop_shot),
		_shot("alpha", "Alpha — fade pulse", _start_alpha, _stop_shot),
		_shot("rotate", "Rotate — spin punch", _start_rotate, _stop_shot),
		_shot("time", "Time — freeze = Engine.time_scale 0", _start_time, _stop_shot),
		_shot("loop", "Loop — breathing scale", _start_loop, _stop_shot),
		_shot("pickup", "Pickup — hop + gold flash", _start_pickup, _stop_shot),
	])
	controller.play_current()


func _center_subject() -> void:
	_subject_default_position = stage.size / 2.0
	subject.position = _subject_default_position
	sine_mover.set_origin_from_target()


func _shot(id: String, title: String, start: Callable, stop: Callable) -> Dictionary:
	return {"id": id, "title": title, "start": start, "stop": stop}


func _arm_loop(seconds: float) -> void:
	_loop_timer.stop()
	if controller.loop_enabled:
		_loop_timer.start(seconds)


func _on_loop_timeout() -> void:
	if controller.loop_enabled:
		controller.replay()


func _stop_shot() -> void:
	_shot_token += 1
	_loop_timer.stop()
	sine_mover.stop_motion(true)
	GameFeelFlow.stop_all(subject)
	subject.position = _subject_default_position
	subject.scale = Vector2.ONE
	subject.rotation = 0.0
	subject.modulate = Color.WHITE
	sine_mover.set_origin_from_target()


func _start_impact() -> void:
	GameFeelFlow.play_combo("hit_light", subject)
	_arm_loop(1.0)


func _start_hit_combo() -> void:
	GameFeelFlow.play_combo("hit_heavy", subject)
	_arm_loop(1.3)


func _start_shake() -> void:
	GameFeelFlow.play("shake_position", subject, {"amplitude": 12.0, "duration": 0.35})
	_arm_loop(1.0)


func _start_flash() -> void:
	# Bleach flash (shader) — turns drawable RGB fully white, then restores.
	GameFeelFlow.play("flash", subject, {"duration": 0.28, "frequency": 6.0})
	_arm_loop(1.0)


func _start_punch() -> void:
	var effect := _build_effect("scale", "elastic") as GFFEffectCommon
	var scale_target := effect.target as GFFScaleTarget
	scale_target.mode = GFFScaleTarget.Mode.BY_AMOUNT
	scale_target.target_value = Vector3(0.35, 0.35, 0.0)
	(effect.tweener as GFFElasticTweener).punch_mode = GFFElasticTweener.PunchMode.TO_ORIGIN
	effect.duration = 0.4
	effect.label = "showcase_punch"
	GameFeelFlow.play(effect, subject)
	_arm_loop(1.1)


func _start_motion() -> void:
	var effect := _build_effect("position", "elastic") as GFFEffectCommon
	var pos_target := effect.target as GFFPositionTarget
	pos_target.mode = GFFPositionTarget.Mode.BY_AMOUNT
	pos_target.target_value = Vector3(0.0, -70.0, 0.0)
	effect.duration = 0.45
	effect.label = "showcase_motion"
	GameFeelFlow.play(effect, subject)
	_arm_loop(1.2)


func _start_color() -> void:
	var effect := _build_effect("color", "linear") as GFFEffectCommon
	var color_target := effect.target as GFFColorTarget
	color_target.target_color = Color(0.35, 0.85, 1.0)
	effect.duration = 0.35
	effect.restore_after_play = true
	effect.restore_mode = GFFEffect.RestoreMode.GRADUAL
	effect.restore_duration = 0.35
	effect.label = "showcase_color"
	GameFeelFlow.play(effect, subject)
	_arm_loop(1.3)


func _start_alpha() -> void:
	var effect := _build_effect("alpha", "linear") as GFFEffectCommon
	(effect.target as GFFAlphaTarget).target_alpha = 0.0
	effect.duration = 0.35
	effect.restore_after_play = true
	effect.restore_mode = GFFEffect.RestoreMode.GRADUAL
	effect.restore_duration = 0.35
	effect.label = "showcase_alpha"
	GameFeelFlow.play(effect, subject)
	_arm_loop(1.3)


func _start_rotate() -> void:
	var effect := _build_effect("rotation", "elastic") as GFFEffectCommon
	var rot_target := effect.target as GFFRotationTarget
	rot_target.mode = GFFRotationTarget.Mode.BY_AMOUNT
	rot_target.target_value = 25.0
	rot_target.use_degrees = true
	effect.duration = 0.4
	effect.label = "showcase_rotate"
	GameFeelFlow.play(effect, subject)
	_arm_loop(1.1)


## Freeze = global Engine.time_scale → 0 via GFFTimeScaleManager.
## Motion is independent sine (_process); freeze only zeros scaled delta.
func _start_time() -> void:
	var token := _shot_token
	sine_mover.amplitude = 120.0
	sine_mover.frequency_hz = 1.4
	sine_mover.set_origin_from_target()
	sine_mover.start_motion()
	# Wait while bobbing (ignore_time_scale so a leftover freeze can't stall this wait).
	await get_tree().create_timer(1.0, true, false, true).timeout
	if token != _shot_token:
		return
	GameFeelFlow.play("freeze_frame", self, {"duration": 0.85})
	_arm_loop(3.2)


func _start_loop() -> void:
	var effect := _build_effect("scale", "linear") as GFFEffectCommon
	var scale_target := effect.target as GFFScaleTarget
	scale_target.mode = GFFScaleTarget.Mode.TO_TARGET
	scale_target.target_value = Vector3(1.12, 1.12, 1.0)
	effect.duration = 1.1
	effect.loop_count = -1
	effect.loop_mode = GFFEffect.LoopMode.PING_PONG
	effect.label = "showcase_loop_breathing"
	GameFeelFlow.play(effect, subject)
	_arm_loop(2.5)


func _start_pickup() -> void:
	GameFeelFlow.play_combo("pickup_coin", subject)
	_arm_loop(1.0)


func _build_effect(target_key: String, tweener_key: String) -> GFFEffect:
	return GFFEffectRegistry.create_effect(target_key, tweener_key)
