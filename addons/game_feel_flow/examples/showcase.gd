extends Control

## Free showcase reel: a loop-current-shot demo strip covering impact, hit combo,
## motion, time, and looping game feel effects. Prev/Next change shots manually;
## Replay restarts the current shot; H (handled by GFFShowcaseController) hides chrome.
## No shot ever auto-advances to the next one.
##
## Subject is a CC0 Kenney character (2D). The same effects work on 3D Node3D targets —
## see the Pro showcase for a 3D mesh example.

const SUBJECT_TEXTURE := preload("res://addons/game_feel_flow/examples/assets/sprites/kenney_character.png")

@onready var stage: Control = $Stage
@onready var subject: Node2D = $Stage/Subject
@onready var subject_sprite: Sprite2D = $Stage/Subject/Sprite
@onready var controller: GFFShowcaseController = $ShowcaseController
@onready var chrome = $CanvasLayer/ShowcaseChrome

var _loop_timer: Timer
var _subject_default_position: Vector2
var _bounce_tween: Tween
var _shot_token: int = 0


func _ready() -> void:
	if subject_sprite and SUBJECT_TEXTURE:
		subject_sprite.texture = SUBJECT_TEXTURE
		# Keep the character large for 16:9 recording (~280px tall).
		var target_h := 280.0
		if subject_sprite.texture.get_height() > 0:
			subject_sprite.scale = Vector2.ONE * (target_h / float(subject_sprite.texture.get_height()))

	_subject_default_position = subject.position
	stage.resized.connect(_center_subject)
	_center_subject()

	chrome.bind_controller(controller)

	_loop_timer = Timer.new()
	_loop_timer.one_shot = true
	add_child(_loop_timer)
	_loop_timer.timeout.connect(_on_loop_timeout)

	controller.set_shots([
		_shot("impact", "Impact — hit_light combo", _start_impact, _stop_shot),
		_shot("hit_combo", "Hit Combo — hit_heavy combo", _start_hit_combo, _stop_shot),
		_shot("motion", "Motion — punch position", _start_motion, _stop_shot),
		_shot("time", "Time — freeze mid-motion", _start_time, _stop_shot),
		_shot("loop", "Loop — breathing scale", _start_loop, _stop_shot),
	])
	controller.play_current()


func _center_subject() -> void:
	_subject_default_position = stage.size / 2.0
	subject.position = _subject_default_position


func _shot(id: String, title: String, start: Callable, stop: Callable) -> Dictionary:
	return {"id": id, "title": title, "start": start, "stop": stop}


func _arm_loop(seconds: float) -> void:
	_loop_timer.stop()
	if controller.loop_enabled:
		_loop_timer.start(seconds)


func _on_loop_timeout() -> void:
	if controller.loop_enabled:
		controller.replay()  # MUST NOT call next_shot


func _stop_shot() -> void:
	_shot_token += 1
	_loop_timer.stop()
	_stop_bounce()
	GameFeelFlow.stop_all(subject)
	subject.position = _subject_default_position
	subject.scale = Vector2.ONE
	subject.rotation = 0.0
	subject.modulate = Color.WHITE


func _stop_bounce() -> void:
	if _bounce_tween and _bounce_tween.is_valid():
		_bounce_tween.kill()
	_bounce_tween = null


func _start_bounce() -> void:
	_stop_bounce()
	subject.position = _subject_default_position
	# Continuous hop that respects Engine.time_scale so freeze_frame can pause it mid-air.
	_bounce_tween = subject.create_tween().set_loops()
	_bounce_tween.tween_property(subject, "position:y", _subject_default_position.y - 140.0, 0.42) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_bounce_tween.tween_property(subject, "position:y", _subject_default_position.y, 0.42) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


# ===== Shot 1: Impact =====
func _start_impact() -> void:
	GameFeelFlow.play_combo("hit_light", subject)
	_arm_loop(1.2)


# ===== Shot 2: Hit Combo =====
func _start_hit_combo() -> void:
	GameFeelFlow.play_combo("hit_heavy", subject)
	_arm_loop(1.5)


# ===== Shot 3: Motion =====
func _start_motion() -> void:
	var effect := _build_effect("position", "elastic") as GFFEffectCommon
	var pos_target := effect.target as GFFPositionTarget
	pos_target.mode = GFFPositionTarget.Mode.BY_AMOUNT
	pos_target.target_value = Vector3(0.0, -70.0, 0.0)
	effect.duration = 0.45
	effect.label = "showcase_motion"
	GameFeelFlow.play(effect, subject)
	_arm_loop(1.2)


# ===== Shot 4: Time — continuous motion, then freeze mid-flight =====
func _start_time() -> void:
	var token := _shot_token
	_start_bounce()
	# Let the hop be visible, then hitstop. ignore_time_scale so the wait itself
	# isn't affected if a previous freeze is somehow still draining.
	await get_tree().create_timer(0.65).timeout
	if token != _shot_token:
		return
	# Host on self — freeze is global (time_scale) and needs a valid tween host.
	GameFeelFlow.play("freeze_frame", self, {"duration": 0.4})
	_arm_loop(2.4)


# ===== Shot 5: Loop =====
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


func _build_effect(target_key: String, tweener_key: String) -> GFFEffect:
	return GFFEffectRegistry.create_effect(target_key, tweener_key)
