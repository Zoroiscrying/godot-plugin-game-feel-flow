extends Control

## Game Feel Flow Effects Demo
##
## 演示所有效果，支持实时调参

# ===== 节点引用 =====
@onready var effect_list: ItemList = $VBoxContainer/EffectList
@onready var param_panel: VBoxContainer = $VBoxContainer/ScrollContainer/ParamPanel
@onready var play_button: Button = $VBoxContainer/HBoxContainer/PlayButton
@onready var reset_button: Button = $VBoxContainer/HBoxContainer/ResetButton
@onready var target_sprite: ColorRect = $TargetSprite

# ===== 效果列表 =====
var effects: Array[Dictionary] = [
	{"name": "Shake", "type": "shake"},
	{"name": "Scale", "type": "scale"},
	{"name": "Flash", "type": "flash"},
	{"name": "Color", "type": "color"},
	{"name": "Alpha", "type": "alpha"},
	{"name": "Freeze Frame", "type": "freeze_frame"},
	{"name": "Time Scale", "type": "time_scale"},
	{"name": "Hit", "type": "hit"},
]

# ===== 生命周期 =====

func _ready() -> void:
	_init_ui()
	_connect_signals()

# ===== 初始化 =====

func _init_ui() -> void:
	for effect in effects:
		effect_list.add_item(effect["name"])

	if not effects.is_empty():
		effect_list.select(0)
		_on_effect_selected(0)

func _connect_signals() -> void:
	effect_list.item_selected.connect(_on_effect_selected)
	play_button.pressed.connect(_on_play_pressed)
	reset_button.pressed.connect(_on_reset_pressed)

# ===== 回调方法 =====

func _on_effect_selected(index: int) -> void:
	if index >= 0 and index < effects.size():
		var effect_type = effects[index]["type"]
		_update_params(effect_type)

func _on_play_pressed() -> void:
	var selected = effect_list.get_selected_items()
	if selected.size() > 0:
		var effect_type = effects[selected[0]]["type"]
		_play_effect(effect_type)

func _on_reset_pressed() -> void:
	_reset_target()

# ===== 效果播放 =====

func _play_effect(effect_type: String) -> void:
	var params = _get_params()
	GameFeelFlow.play(effect_type, target_sprite, params)

func _reset_target() -> void:
	target_sprite.position = Vector2.ZERO
	target_sprite.rotation = 0
	target_sprite.scale = Vector2.ONE
	target_sprite.modulate = Color.WHITE

# ===== 参数管理 =====

func _update_params(effect_type: String) -> void:
	for child in param_panel.get_children():
		child.queue_free()

	match effect_type:
		"shake":
			_add_float_param("intensity", 1.0, 0.0, 3.0)
			_add_float_param("duration", 0.15, 0.01, 0.5)
			_add_float_param("amplitude", 3.0, 0.5, 10.0)
		"scale":
			_add_float_param("intensity", 1.0, 0.0, 3.0)
			_add_float_param("duration", 0.15, 0.01, 0.5)
		"flash":
			_add_float_param("intensity", 1.0, 0.0, 3.0)
			_add_float_param("duration", 0.1, 0.01, 0.3)
			_add_color_param("color", Color.WHITE)
		"color":
			_add_float_param("intensity", 1.0, 0.0, 3.0)
			_add_float_param("duration", 0.15, 0.01, 0.3)
			_add_color_param("color", Color.RED)
		"alpha":
			_add_float_param("intensity", 1.0, 0.0, 3.0)
			_add_float_param("duration", 0.15, 0.01, 0.3)
		"freeze_frame":
			_add_float_param("duration", 0.05, 0.01, 0.2)
		"time_scale":
			_add_float_param("duration", 0.2, 0.01, 1.0)
			_add_float_param("scale", 0.5, 0.1, 1.0)
		"hit":
			_add_float_param("intensity", 1.0, 0.0, 3.0)
			_add_float_param("duration", 0.15, 0.01, 0.5)
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
