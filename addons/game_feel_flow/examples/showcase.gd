extends Control

## Free showcase reel. Prev/Next change shots manually; Replay restarts;
## H hides chrome. No auto-advance.
##
## Standard workflow: effects live on Subject/GFFPlayer.combo_dictionary
## (see examples/resources/showcase_combos/). Shots only call play_combo().

const SUBJECT_TEXTURE := preload("res://addons/game_feel_flow/examples/assets/sprites/kenney_prop.png")

@onready var stage: Control = $Stage
@onready var subject: Node2D = $SubjectLayer/Subject
@onready var subject_sprite: Sprite2D = $SubjectLayer/Subject/Sprite
@onready var player: GFFPlayer = $SubjectLayer/Subject/GFFPlayer
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
		_shot("impact", "Impact — GFFPlayer play_combo(\"impact\")", _start_impact, _stop_shot),
		_shot("hit_combo", "Hit Combo — play_combo(\"hit_combo\")", _start_hit_combo, _stop_shot),
		_shot("shake", "Shake — combo on Subject/GFFPlayer", _start_shake, _stop_shot),
		_shot("flash", "Flash — bleach via flash combo", _start_flash, _stop_shot),
		_shot("punch", "Punch — elastic scale combo", _start_punch, _stop_shot),
		_shot("motion", "Motion — hop position combo", _start_motion, _stop_shot),
		_shot("color", "Color — tint pulse combo", _start_color, _stop_shot),
		_shot("alpha", "Alpha — fade pulse combo", _start_alpha, _stop_shot),
		_shot("rotate", "Rotate — spin punch combo", _start_rotate, _stop_shot),
		_shot("time", "Time — sine bob + freeze combo", _start_time, _stop_shot),
		_shot("loop", "Loop — breathing scale combo", _start_loop, _stop_shot),
		_shot("pickup", "Pickup — play_combo(\"pickup\")", _start_pickup, _stop_shot),
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
	player.stop()
	GameFeelFlow.stop_all(subject)
	subject.position = _subject_default_position
	subject.scale = Vector2.ONE
	subject.rotation = 0.0
	subject.modulate = Color.WHITE
	sine_mover.set_origin_from_target()


func _play(combo_key: String, loop_seconds: float) -> void:
	player.play_combo(combo_key)
	_arm_loop(loop_seconds)


func _start_impact() -> void:
	_play("impact", 1.0)


func _start_hit_combo() -> void:
	_play("hit_combo", 1.3)


func _start_shake() -> void:
	_play("shake", 1.0)


func _start_flash() -> void:
	_play("flash", 1.0)


func _start_punch() -> void:
	_play("punch", 1.1)


func _start_motion() -> void:
	_play("motion", 1.2)


func _start_color() -> void:
	_play("color", 1.3)


func _start_alpha() -> void:
	_play("alpha", 1.3)


func _start_rotate() -> void:
	_play("rotate", 1.1)


## Freeze = global Engine.time_scale → 0. Motion is independent sine (_process).
func _start_time() -> void:
	var token := _shot_token
	sine_mover.amplitude = 120.0
	sine_mover.frequency_hz = 1.4
	sine_mover.set_origin_from_target()
	sine_mover.start_motion()
	await get_tree().create_timer(1.0, true, false, true).timeout
	if token != _shot_token:
		return
	player.play_combo("time")
	_arm_loop(3.2)


func _start_loop() -> void:
	_play("loop", 2.5)


func _start_pickup() -> void:
	_play("pickup", 1.0)
