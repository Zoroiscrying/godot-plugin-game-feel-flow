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

# ===== Effect Selection =====

func _on_effect_selected(index: int) -> void:
	if index >= 0 and index < effects.size():
		var effect_type = effects[index]["type"]
		_update_params(effect_type)

# ===== Effect Playback =====

func _play_effect(effect_type: String) -> void:
	var params = _get_params()
	print("Playing: ", effect_type, " with params: ", params)

	match effect_type:
		"button_press":
			# Simple scale animation using Tween
			var tween = demo_button.create_tween()
			tween.tween_property(demo_button, "scale", Vector2(0.9, 0.9), 0.05)
			tween.tween_property(demo_button, "scale", Vector2(1.0, 1.0), 0.1)
		"sprite_scale":
			GFUtil.scale(demo_sprite, params.get_float("intensity", 1.0))
		"sprite_color":
			GFUtil.color(demo_sprite, params.get_color("color", Color.RED))
		"hit_light":
			GFUtil.hit(demo_sprite, params.get_float("intensity", 1.0))
		"hit_medium":
			GFUtil.hit_heavy(demo_sprite, params.get_float("intensity", 1.0))

func _reset() -> void:
	demo_sprite.position = _original_sprite_position
	demo_sprite.scale = _original_sprite_scale
	demo_sprite.modulate = Color.WHITE
	demo_label.text = "Waiting..."
	demo_progress.value = 0
	print("Reset")

# ===== Parameter Management =====

func _update_params(effect_type: String) -> void:
	# Clear existing params
	for child in param_panel.get_children():
		child.queue_free()
	
	# Add params based on effect type
	match effect_type:
		"button_press":
			_add_float_param("duration", 0.1, 0.01, 0.5)
		"sprite_scale":
			_add_float_param("intensity", 1.0, 0.0, 3.0)
			_add_float_param("duration", 0.15, 0.01, 0.5)
		"sprite_color":
			_add_float_param("intensity", 1.0, 0.0, 3.0)
			_add_float_param("duration", 0.15, 0.01, 0.3)
			_add_color_param("color", Color.RED)
		"hit_light", "hit_medium":
			_add_float_param("intensity", 1.0, 0.0, 3.0)
		_:
			_add_float_param("intensity", 1.0, 0.0, 3.0)
			_add_float_param("duration", 0.15, 0.01, 0.5)

func _add_float_param(param_name: String, default: float, min_val: float, max_val: float) -> void:
	var hbox = HBoxContainer.new()
	
	var label = Label.new()
	label.text = param_name
	label.custom_minimum_size.x = 100
	hbox.add_child(label)
	
	var slider = HSlider.new()
	slider.min_value = min_val
	slider.max_value = max_val
	slider.value = default
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.name = param_name
	hbox.add_child(slider)
	
	var value_label = Label.new()
	value_label.text = "%.2f" % default
	value_label.custom_minimum_size.x = 50
	hbox.add_child(value_label)
	
	slider.value_changed.connect(func(value): value_label.text = "%.2f" % value)
	
	param_panel.add_child(hbox)

func _add_color_param(param_name: String, default: Color) -> void:
	var hbox = HBoxContainer.new()
	
	var label = Label.new()
	label.text = param_name
	label.custom_minimum_size.x = 100
	hbox.add_child(label)
	
	var color_picker = ColorPickerButton.new()
	color_picker.color = default
	color_picker.name = param_name
	hbox.add_child(color_picker)
	
	param_panel.add_child(hbox)

func _get_params() -> GFFParams:
	var params = GFFParams.new()
	
	for child in param_panel.get_children():
		if child is HBoxContainer:
			for subchild in child.get_children():
				if subchild is HSlider:
					if subchild.name == "intensity":
						params.intensity = subchild.value
					elif subchild.name == "duration":
						params.duration = subchild.value
					else:
						params.with_float(subchild.name, subchild.value)
				elif subchild is ColorPickerButton:
					params.with_color(subchild.name, subchild.color)
	
	return params

# ===== Callbacks =====

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
