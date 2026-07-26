extends Control

## Free onboarding: a short 3-step teaching flow for GFFPlayer + Combos.
## Step 1 — add a GFFPlayer and play "hit_light".
## Step 2 — combos stack multiple effects (hit_heavy layers shake/flash/scale).
## Step 3 — effects can loop for ambient feel; "Open EffectLibrary" opens
## effect_library.tscn for the full catalog.

const EFFECT_LIBRARY_SCENE_PATH := "res://addons/game_feel_flow/examples/effect_library.tscn"

const STEPS: Array[Dictionary] = [
	{
		"title": "Step 1 / 3 — Add a GFFPlayer and play a combo",
		"body": "Add a GFFPlayer node as a child of the object you want to juice, then call play_combo() with a built-in combo name.",
		"action_label": "Play hit_light",
		"combo": "hit_light",
		"effects_text": "",
	},
	{
		"title": "Step 2 / 3 — Combos stack multiple effects",
		"body": "A single combo can drive several effects at once. hit_heavy layers:",
		"action_label": "Play hit_heavy",
		"combo": "hit_heavy",
		"effects_text": "• Shake — position jitter\n• Flash — white color pulse\n• Scale punch — impact squash",
	},
	{
		"title": "Step 3 / 3 — Loops for ambient feel",
		"body": "Effects can loop indefinitely too, great for idle breathing, warnings, or ambient motion.",
		"action_label": "Play Loop",
		"combo": "",
		"effects_text": "",
	},
]

@onready var stage: Control = $Stage
@onready var subject: Node2D = $Stage/Subject
@onready var player: GFFPlayer = $Stage/Subject/GFFPlayer
@onready var step_title_label: Label = $CanvasLayer/StepChrome/Margin/HBox/TitleLabel
@onready var next_btn: Button = $CanvasLayer/StepChrome/Margin/HBox/NextButton
@onready var body_label: Label = $CanvasLayer/ContentPanel/Margin/VBox/BodyLabel
@onready var effects_label: Label = $CanvasLayer/ContentPanel/Margin/VBox/EffectsLabel
@onready var action_btn: Button = $CanvasLayer/ContentPanel/Margin/VBox/ActionButton

var _step_index: int = 0
var _loop_timer: Timer


func _ready() -> void:
	stage.resized.connect(_center_subject)
	_center_subject()

	_loop_timer = Timer.new()
	_loop_timer.one_shot = true
	add_child(_loop_timer)
	_loop_timer.timeout.connect(_on_loop_timeout)

	next_btn.pressed.connect(_on_next_pressed)
	action_btn.pressed.connect(_on_action_pressed)

	_show_step(0)


func _center_subject() -> void:
	subject.position = stage.size / 2.0


func _show_step(index: int) -> void:
	_reset_stage()
	_step_index = clampi(index, 0, STEPS.size() - 1)
	var step: Dictionary = STEPS[_step_index]
	step_title_label.text = step["title"]
	body_label.text = step["body"]
	action_btn.text = step["action_label"]
	effects_label.text = step["effects_text"]
	effects_label.visible = not (step["effects_text"] as String).is_empty()
	next_btn.text = "Open EffectLibrary" if _step_index == STEPS.size() - 1 else "Next Step"


func _on_next_pressed() -> void:
	if _step_index == STEPS.size() - 1:
		_open_effect_library()
		return
	_show_step(_step_index + 1)


func _on_action_pressed() -> void:
	match _step_index:
		0, 1:
			player.play_combo(STEPS[_step_index]["combo"])
		2:
			_play_ambient_loop()


func _play_ambient_loop() -> void:
	_reset_stage()
	var effect := _build_effect("scale", "linear") as GFFEffectCommon
	var scale_target := effect.target as GFFScaleTarget
	scale_target.mode = GFFScaleTarget.Mode.TO_TARGET
	scale_target.target_value = Vector3(1.12, 1.12, 1.0)
	effect.duration = 1.1
	effect.loop_count = -1
	effect.loop_mode = GFFEffect.LoopMode.PING_PONG
	effect.label = "onboarding_loop_breathing"
	player.play(effect)
	_loop_timer.start(4.0)


func _on_loop_timeout() -> void:
	_reset_stage()


func _reset_stage() -> void:
	_loop_timer.stop()
	player.stop()
	subject.scale = Vector2.ONE
	subject.modulate = Color.WHITE


func _open_effect_library() -> void:
	if ResourceLoader.exists(EFFECT_LIBRARY_SCENE_PATH):
		get_tree().change_scene_to_file(EFFECT_LIBRARY_SCENE_PATH)
	else:
		push_warning("Onboarding: EffectLibrary scene not available yet: " + EFFECT_LIBRARY_SCENE_PATH)


func _build_effect(target_key: String, tweener_key: String) -> GFFEffect:
	return GFFEffectRegistry.create_effect(target_key, tweener_key)
