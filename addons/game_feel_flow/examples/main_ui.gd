extends Control

## Game Feel Flow UI Main Scene

@onready var effect_list: ItemList = $Panel/VBoxContainer/EffectList
@onready var param_panel: VBoxContainer = $Panel/VBoxContainer/ScrollContainer/ParamPanel
@onready var play_button: Button = $Panel/VBoxContainer/HBoxContainer/PlayButton
@onready var reset_button: Button = $Panel/VBoxContainer/HBoxContainer/ResetButton

@onready var demo_button: Button = $DemoArea/DemoButton
@onready var demo_label: Label = $DemoArea/DemoLabel
@onready var demo_progress: ProgressBar = $DemoArea/DemoProgress
@onready var demo_sprite: ColorRect = $DemoArea/DemoSprite

# ===== Original Values =====
var _original_sprite_position: Vector2 = Vector2.ZERO
var _original_sprite_scale: Vector2 = Vector2.ONE

# ===== Effect List =====
var effects: Array[Dictionary] = [
	{"name": "Button Press", "type": "button_press"},
	{"name": "Sprite Scale", "type": "sprite_scale"},
	{"name": "Sprite Color", "type": "sprite_color"},
	{"name": "Hit Light", "type": "hit_light"},
	{"name": "Hit Medium", "type": "hit_medium"},
]

# ===== Lifecycle =====

func _ready() -> void:
	print("=== Game Feel Flow UI ===")
	print("Select an effect, then click Play")

	_store_original()
	_init_ui()

	effect_list.item_selected.connect(_on_effect_selected)
	play_button.pressed.connect(_on_play_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	demo_button.pressed.connect(_on_demo_pressed)

func _store_original() -> void:
	_original_sprite_position = demo_sprite.position
	_original_sprite_scale = demo_sprite.scale

func _init_ui() -> void:
	for effect in effects:
		effect_list.add_item(effect["name"])

# ===== Effect Playback =====

func _play_effect(effect_type: String) -> void:
	print("Playing: ", effect_type)

	match effect_type:
		"button_press":
			# Simple scale animation using Tween
			var tween = demo_button.create_tween()
			tween.tween_property(demo_button, "scale", Vector2(0.9, 0.9), 0.05)
			tween.tween_property(demo_button, "scale", Vector2(1.0, 1.0), 0.1)
		"sprite_scale":
			GameFeelFlow.play("scale", demo_sprite)
		"sprite_color":
			GameFeelFlow.play("color", demo_sprite)
		"hit_light":
			GameFeelFlow.play_combo("hit_light", demo_sprite)
		"hit_medium":
			GameFeelFlow.play_combo("hit_heavy", demo_sprite)

func _reset() -> void:
	demo_sprite.position = _original_sprite_position
	demo_sprite.scale = _original_sprite_scale
	demo_sprite.modulate = Color.WHITE
	demo_label.text = "Waiting..."
	demo_progress.value = 0
	print("Reset")

# ===== Callbacks =====

func _on_effect_selected(index: int) -> void:
	if index >= 0 and index < effects.size():
		param_panel.show_params(effects[index]["type"])

func _on_play_pressed() -> void:
	var selected = effect_list.get_selected_items()
	if selected.size() > 0:
		_play_effect(effects[selected[0]]["type"])

func _on_reset_pressed() -> void:
	_reset()

func _on_demo_pressed() -> void:
	_play_effect("button_press")
	demo_label.text = "Clicked!"
	demo_progress.value = min(demo_progress.value + 10, 100)
