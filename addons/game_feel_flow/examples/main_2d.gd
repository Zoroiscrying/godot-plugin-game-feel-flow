extends Node2D

## Game Feel Flow 2D Main Scene

@onready var sprite: ColorRect = $Sprite2D
@onready var camera: Camera2D = $Camera2D
@onready var effect_list: ItemList = $UI/Panel/VBoxContainer/EffectList
@onready var param_panel: VBoxContainer = $UI/Panel/VBoxContainer/ScrollContainer/ParamPanel
@onready var play_button: Button = $UI/Panel/VBoxContainer/HBoxContainer/PlayButton
@onready var reset_button: Button = $UI/Panel/VBoxContainer/HBoxContainer/ResetButton

# ===== Original Values =====
var _original_position: Vector2 = Vector2.ZERO
var _original_scale: Vector2 = Vector2.ONE
var _original_rotation: float = 0.0
var _original_color: Color = Color.WHITE

# ===== Effect List =====
var effects: Array[Dictionary] = [
	{"name": "Shake", "type": "shake"},
	{"name": "Scale", "type": "scale"},
	{"name": "Color", "type": "color"},
	{"name": "Alpha", "type": "alpha"},
	{"name": "Flash", "type": "flash"},
	{"name": "Freeze Frame", "type": "freeze_frame"},
	{"name": "Time Scale", "type": "time_scale"},
	{"name": "Hit Light", "type": "hit_light"},
	{"name": "Hit Medium", "type": "hit_medium"},
	{"name": "Hit Heavy", "type": "hit_heavy"},
	{"name": "Hit Critical", "type": "hit_critical"},
	{"name": "Explosion", "type": "explosion"},
	{"name": "Death", "type": "death"},
]

# ===== Lifecycle =====

func _ready() -> void:
	print("=== Game Feel Flow 2D ===")
	print("Select an effect, then click Play")

	_store_original()
	_init_ui()

	effect_list.item_selected.connect(_on_effect_selected)
	play_button.pressed.connect(_on_play_pressed)
	reset_button.pressed.connect(_on_reset_pressed)

func _store_original() -> void:
	_original_position = sprite.position
	_original_scale = sprite.scale
	_original_rotation = sprite.rotation
	_original_color = sprite.modulate

func _init_ui() -> void:
	for effect in effects:
		effect_list.add_item(effect["name"])

# ===== Effect Selection =====

func _on_effect_selected(index: int) -> void:
	if index >= 0 and index < effects.size():
		var effect_type = effects[index]["type"]
		param_panel.show_params(effect_type)

# ===== Effect Playback =====

func _play_effect(effect_type: String) -> void:
	print("Playing: ", effect_type)

	match effect_type:
		"shake":
			GameFeelFlow.play("shake", sprite)
		"scale":
			GameFeelFlow.play("scale", sprite)
		"color":
			GameFeelFlow.play("color", sprite)
		"alpha":
			GameFeelFlow.play("alpha", sprite)
		"flash":
			GameFeelFlow.play("flash", sprite)
		"freeze_frame":
			GameFeelFlow.play("freeze_frame", sprite)
		"time_scale":
			GameFeelFlow.play("time_scale", sprite)
		"hit_light":
			GameFeelFlow.play_combo("hit_light", sprite)
		"hit_medium":
			GameFeelFlow.play_combo("hit_heavy", sprite)
		"hit_heavy":
			GameFeelFlow.play_combo("hit_heavy", sprite)
		"explosion":
			GameFeelFlow.play_combo("explosion", sprite)
		"death":
			GameFeelFlow.play_combo("death", sprite)

func _reset() -> void:
	sprite.position = _original_position
	sprite.scale = _original_scale
	sprite.rotation = _original_rotation
	sprite.modulate = _original_color
	Engine.time_scale = 1.0
	print("Reset")

# ===== Callbacks =====

func _on_play_pressed() -> void:
	var selected = effect_list.get_selected_items()
	if selected.size() > 0:
		_play_effect(effects[selected[0]]["type"])
	else:
		print("Please select an effect first")

func _on_reset_pressed() -> void:
	_reset()
