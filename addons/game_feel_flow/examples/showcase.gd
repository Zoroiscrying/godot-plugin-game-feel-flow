extends Control

## Free showcase reel: a loop-current-shot demo strip covering impact, hit combo,
## motion, time, and looping game feel effects. Prev/Next change shots manually;
## Replay restarts the current shot; H (handled by GFFShowcaseController) hides chrome.
## No shot ever auto-advances to the next one.

@onready var stage: Control = $Stage
@onready var subject: Node2D = $Stage/Subject
@onready var controller: GFFShowcaseController = $ShowcaseController
@onready var chrome = $CanvasLayer/ShowcaseChrome

var _loop_timer: Timer
var _subject_default_position: Vector2


func _ready() -> void:
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
		_shot("time", "Time — freeze frame", _start_time, _stop_shot),
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
	_loop_timer.stop()
	GameFeelFlow.stop_all(subject)
	subject.position = _subject_default_position
	subject.scale = Vector2.ONE
	subject.rotation = 0.0
	subject.modulate = Color.WHITE


# ===== Shot 1: Impact =====
func _start_impact() -> void:
	GameFeelFlow.play_combo("hit_light", subject)
	_arm_loop(1.2)


# ===== Shot 2: Hit Combo =====
func _start_hit_combo() -> void:
	GameFeelFlow.play_combo("hit_heavy", subject)
	_arm_loop(1.5)


# ===== Shot 3: Motion =====
# The registered "punch_position" preset defaults its target offset to zero,
# so it produces no visible motion out of the box. Build a real hop using the
# same Target/Tweener building blocks the registry itself uses.
func _start_motion() -> void:
	var effect := _build_effect("position", "elastic") as GFFEffectCommon
	var pos_target := effect.target as GFFPositionTarget
	pos_target.mode = GFFPositionTarget.Mode.BY_AMOUNT
	pos_target.target_value = Vector3(0.0, -70.0, 0.0)
	effect.duration = 0.45
	effect.label = "showcase_motion"
	GameFeelFlow.play(effect, subject)
	_arm_loop(1.2)


# ===== Shot 4: Time =====
func _start_time() -> void:
	var punch := _build_effect("scale", "elastic") as GFFEffectCommon
	var scale_target := punch.target as GFFScaleTarget
	scale_target.mode = GFFScaleTarget.Mode.BY_AMOUNT
	scale_target.target_value = Vector3(0.3, 0.3, 0.0)
	punch.duration = 0.5
	punch.label = "showcase_time_punch"
	GameFeelFlow.play(punch, subject)
	GameFeelFlow.play("freeze_frame", subject, {"duration": 0.18})
	_arm_loop(1.5)


# ===== Shot 5: Loop =====
# Mirrors the loop_breathing.tscn pattern: a scale effect that pings-pong loops
# forever until stop() is called by _stop_shot / GameFeelFlow.stop_all.
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
