extends Node2D

## Game Feel Flow 2D Main Scene

@onready var sprite: Sprite2D = $Sprite2D
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
var _original_camera_position: Vector2 = Vector2.ZERO
var _original_camera_zoom: Vector2 = Vector2.ONE

# ===== Effect List =====
var effects: Array[Dictionary] = [
	{"name": "Shake Position", "type": "shake_position"},
	{"name": "Shake Scale", "type": "shake_scale"},
	{"name": "Punch Scale", "type": "punch_scale"},
	{"name": "Color", "type": "color"},
	{"name": "Alpha", "type": "alpha"},
	{"name": "Flash", "type": "flash"},
	{"name": "Freeze Frame", "type": "freeze_frame"},
	{"name": "Time Scale", "type": "time_scale"},
	{"name": "Camera Shake", "type": "camera_shake"},
	{"name": "Camera Zoom", "type": "camera_zoom"},
	{"name": "Hit Light", "type": "hit_light"},
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
	_original_camera_position = camera.position
	_original_camera_zoom = camera.zoom

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
	# Stop in-flight effects and snap back before replaying, otherwise stacked
	# shakes capture the mid-offset as the new "initial" and never settle.
	GameFeelFlow.stop_all(self)
	_restore_transforms()

	var params = _get_params()
	print("Playing: ", effect_type, " with params: ", params)

	match effect_type:
		"shake_position":
			GameFeelFlow.play("shake_position", sprite, params)
		"shake_scale":
			GameFeelFlow.play("shake_scale", sprite, params)
		"punch_scale":
			GameFeelFlow.play("punch_scale", sprite, params)
		"color":
			GameFeelFlow.play("color", sprite, params)
		"alpha":
			GameFeelFlow.play("alpha", sprite, params)
		"flash":
			GameFeelFlow.play("flash", sprite, params)
		"freeze_frame":
			GameFeelFlow.play("freeze_frame", sprite, params)
		"time_scale":
			GameFeelFlow.play("time_scale", sprite, params)
		"camera_shake":
			GameFeelFlow.play("camera_shake", camera, params)
		"camera_zoom":
			GameFeelFlow.play("camera_zoom", camera, params)
		"hit_light":
			GameFeelFlow.play_combo("hit_light", sprite, params)
		"explosion":
			GameFeelFlow.play_combo("explosion", sprite, params)
		"death":
			GameFeelFlow.play_combo("death", sprite, params)

func _restore_transforms() -> void:
	sprite.position = _original_position
	sprite.scale = _original_scale
	sprite.rotation = _original_rotation
	sprite.modulate = _original_color
	camera.position = _original_camera_position
	camera.zoom = _original_camera_zoom
	Engine.time_scale = 1.0

func _reset() -> void:
	GameFeelFlow.stop_all(self)
	_restore_transforms()
	print("Reset")

# ===== Parameter Management =====

func _update_params(effect_type: String) -> void:
	# Clear existing params
	for child in param_panel.get_children():
		child.queue_free()

	# Add params based on effect type
	match effect_type:
		"shake_position":
			_add_float_param("intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param("duration", 0.3, 0.01, 1.0, 0.01)
			_add_float_param("amplitude", 0.5, 0.1, 5.0, 0.1)
			_add_float_param("frequency", 15.0, 5.0, 50.0, 1.0)
		"shake_scale":
			_add_float_param("intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param("duration", 0.3, 0.01, 1.0, 0.01)
			_add_float_param("amplitude", 0.2, 0.05, 2.0, 0.05)
			_add_float_param("frequency", 15.0, 5.0, 50.0, 1.0)
		"punch_scale":
			_add_float_param("intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param("duration", 0.3, 0.01, 1.0, 0.01)
			_add_float_param("target_x", 0.3, 0.0, 1.0, 0.1)
			_add_float_param("target_y", 0.3, 0.0, 1.0, 0.1)
			_add_float_param("elasticity", 0.5, 0.0, 1.0, 0.1)
			_add_option_param("punch_mode", ["To Target", "To Origin"])
		"flash":
			_add_float_param("intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param("duration", 0.1, 0.01, 0.3, 0.01)
			_add_float_param("frequency", 15.0, 5.0, 30.0, 1.0)
			_add_color_param("color", Color.WHITE)
		"color":
			_add_float_param("intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param("duration", 0.3, 0.01, 0.5, 0.01)
			_add_color_param("color", Color.RED)
		"alpha":
			_add_float_param("intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param("duration", 0.3, 0.01, 0.5, 0.01)
			_add_float_param("target_alpha", 0.0, 0.0, 1.0, 0.1)
		"freeze_frame":
			_add_float_param("duration", 0.05, 0.01, 0.2, 0.01)
		"time_scale":
			_add_float_param("duration", 0.2, 0.01, 1.0, 0.01)
			_add_float_param("time_scale", 0.5, 0.1, 1.0, 0.1)
		"camera_shake":
			_add_float_param("intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param("duration", 0.3, 0.01, 1.0, 0.01)
			_add_float_param("amplitude", 0.5, 0.1, 5.0, 0.1)
			_add_float_param("frequency", 15.0, 5.0, 50.0, 1.0)
		"camera_zoom":
			_add_float_param("intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param("duration", 0.3, 0.01, 1.0, 0.01)
		"hit_light", "explosion", "death":
			_add_float_param("intensity", 1.0, 0.0, 3.0, 0.1)
		_:
			_add_float_param("intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param("duration", 0.3, 0.01, 1.0, 0.01)

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

func _add_option_param(param_name: String, options: Array[String]) -> void:
	var hbox = HBoxContainer.new()

	var label = Label.new()
	label.text = param_name
	label.custom_minimum_size.x = 100
	hbox.add_child(label)

	var option_button = OptionButton.new()
	for i in range(options.size()):
		option_button.add_item(options[i], i)
	option_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	option_button.name = param_name
	hbox.add_child(option_button)

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
				elif subchild is OptionButton:
					params.with_int(subchild.name, subchild.selected)

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
