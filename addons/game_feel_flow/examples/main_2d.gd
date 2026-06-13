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
	{"name": "Hit Medium", "type": "hit_heavy"},
	{"name": "Hit Heavy", "type": "hit_heavy"},
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
		_update_params(effect_type)

# ===== Effect Playback =====

func _play_effect(effect_type: String) -> void:
	var params = _get_params()
	print("Playing: ", effect_type, " with params: ", params)

	match effect_type:
		"shake":
			GFUtil.shake(sprite, params.get_float("intensity", 1.0))
		"scale":
			GFUtil.scale(sprite, params.get_float("intensity", 1.0))
		"color":
			GFUtil.color(sprite, params.get_color("color", Color.RED))
		"alpha":
			GFUtil.alpha(sprite, params.get_float("target_alpha", 0.0))
		"flash":
			GFUtil.flash(sprite, params.get_color("color", Color.WHITE))
		"freeze_frame":
			GFUtil.freeze(params.get_float("duration", 0.05))
		"time_scale":
			GFUtil.slow_motion(params.get_float("duration", 1.0), params.get_float("scale", 0.3))
		"hit_light":
			GFUtil.hit(sprite, params.get_float("intensity", 1.0))
		"hit_medium":
			GFUtil.hit_heavy(sprite, params.get_float("intensity", 1.0))
		"hit_heavy":
			GFUtil.hit_heavy(sprite, params.get_float("intensity", 1.0))
		"explosion":
			GFUtil.explosion(sprite, params.get_float("intensity", 1.0))
		"death":
			GFUtil.death(sprite, params.get_float("intensity", 1.0))

func _reset() -> void:
	sprite.position = _original_position
	sprite.scale = _original_scale
	sprite.rotation = _original_rotation
	sprite.modulate = _original_color
	Engine.time_scale = 1.0
	print("Reset")

# ===== Parameter Management =====

func _update_params(effect_type: String) -> void:
	# Clear existing params
	for child in param_panel.get_children():
		child.queue_free()
	
	# Add params based on effect type
	match effect_type:
		"shake":
			_add_float_param("intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param("duration", 0.1, 0.01, 0.5, 0.01)
			_add_float_param("amplitude", 0.1, 0.01, 1.0, 0.01)
			_add_float_param("frequency", 15.0, 5.0, 50.0, 1.0)
		"scale":
			_add_float_param("intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param("duration", 0.1, 0.01, 0.5, 0.01)
		"flash":
			_add_float_param("intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param("duration", 0.1, 0.01, 0.3, 0.01)
			_add_color_param("color", Color.WHITE)
		"color":
			_add_float_param("intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param("duration", 0.1, 0.01, 0.3, 0.01)
			_add_color_param("color", Color.RED)
		"alpha":
			_add_float_param("intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param("duration", 0.1, 0.01, 0.3, 0.01)
		"freeze_frame":
			_add_float_param("duration", 0.05, 0.01, 0.2, 0.01)
		"time_scale":
			_add_float_param("duration", 0.2, 0.01, 1.0, 0.01)
			_add_float_param("scale", 0.5, 0.1, 1.0, 0.1)
		"hit_light", "hit_heavy", "explosion", "death":
			_add_float_param("intensity", 1.0, 0.0, 3.0, 0.1)
		_:
			_add_float_param("intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param("duration", 0.1, 0.01, 0.5, 0.01)

func _add_float_param(param_name: String, default: float, min_val: float, max_val: float, step: float = 0.01) -> void:
	var hbox = HBoxContainer.new()
	
	var label = Label.new()
	label.text = param_name
	label.custom_minimum_size.x = 100
	hbox.add_child(label)
	
	var slider = HSlider.new()
	slider.min_value = min_val
	slider.max_value = max_val
	slider.value = default
	slider.step = step
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
	else:
		print("Please select an effect first")

func _on_reset_pressed() -> void:
	_reset()
