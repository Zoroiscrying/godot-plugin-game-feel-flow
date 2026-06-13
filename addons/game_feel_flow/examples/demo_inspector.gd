extends Control

## Game Feel Flow Inspector Demo
##
## 提供调参界面，让用户实时调整效果参数

# ===== 节点引用 =====
@onready var effect_list: ItemList = $VBoxContainer/HSplitContainer/EffectList
@onready var param_panel: VBoxContainer = $VBoxContainer/HSplitContainer/ParamPanel
@onready var preview_viewport: SubViewportContainer = $VBoxContainer/HSplitContainer/PreviewContainer
@onready var preview_target: ColorRect = $VBoxContainer/HSplitContainer/PreviewContainer/Target
@onready var play_button: Button = $VBoxContainer/HBoxContainer/PlayButton
@onready var reset_button: Button = $VBoxContainer/HBoxContainer/ResetButton
@onready var code_label: Label = $VBoxContainer/CodeLabel

# ===== 效果列表 =====
var effects: Array[Dictionary] = [
	{"name": "Shake", "type": "shake"},
	{"name": "Scale", "type": "scale"},
	{"name": "Flash", "type": "flash"},
	{"name": "Color", "type": "color"},
	{"name": "Alpha", "type": "alpha"},
	{"name": "Freeze Frame", "type": "freeze_frame"},
	{"name": "Time Scale", "type": "time_scale"},
	{"name": "Hit Light", "type": "hit_light"},
	{"name": "Hit Heavy", "type": "hit_heavy"},
	{"name": "Death", "type": "death"},
	{"name": "Pickup", "type": "pickup"},
	{"name": "Explosion", "type": "explosion"},
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
		_update_code_preview(effect_type)

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
	
	match effect_type:
		"shake":
			GFUtil.shake(preview_target, params.get_float("intensity", 1.0))
		"scale":
			GFUtil.scale(preview_target, params.get_float("intensity", 1.0))
		"flash":
			GFUtil.flash(preview_target, params.get_color("color", Color.WHITE))
		"color":
			GFUtil.color(preview_target, params.get_color("color", Color.RED))
		"alpha":
			GFUtil.alpha(preview_target, params.get_float("target_alpha", 0.0))
		"freeze_frame":
			GFUtil.freeze(params.get_float("duration", 0.05))
		"time_scale":
			GFUtil.slow_motion(params.get_float("duration", 1.0), params.get_float("scale", 0.3))
		"hit_light":
			GFUtil.hit(preview_target, params.get_float("intensity", 1.0))
		"hit_heavy":
			GFUtil.hit_heavy(preview_target, params.get_float("intensity", 1.0))
		"death":
			GFUtil.death(preview_target, params.get_float("intensity", 1.0))
		"pickup":
			GFUtil.pickup(preview_target, params.get_float("intensity", 1.0))
		"explosion":
			GFUtil.explosion(preview_target, params.get_float("intensity", 1.0))

func _reset_target() -> void:
	preview_target.position = Vector2.ZERO
	preview_target.scale = Vector2.ONE
	preview_target.rotation = 0
	preview_target.modulate = Color.WHITE

# ===== 参数管理 =====

func _update_params(effect_type: String) -> void:
	for child in param_panel.get_children():
		child.queue_free()
	
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
		"hit_light", "hit_heavy", "death", "pickup", "explosion":
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
	
	slider.value_changed.connect(func(value): 
		value_label.text = "%.2f" % value
		_update_code_preview(effects[effect_list.get_selected_items()[0]]["type"] if effect_list.get_selected_items().size() > 0 else "")
	)
	
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
	
	color_picker.color_changed.connect(func(color): 
		_update_code_preview(effects[effect_list.get_selected_items()[0]]["type"] if effect_list.get_selected_items().size() > 0 else "")
	)
	
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

# ===== 代码预览 =====

func _update_code_preview(effect_type: String) -> void:
	var params = _get_params()
	var code = ""
	
	match effect_type:
		"shake":
			code = 'GFUtil.shake(target, %.1f)' % params.get_float("intensity", 1.0)
		"scale":
			code = 'GFUtil.scale(target, %.1f)' % params.get_float("intensity", 1.0)
		"flash":
			code = 'GFUtil.flash(target, Color.WHITE)'
		"color":
			code = 'GFUtil.color(target, Color.RED)'
		"alpha":
			code = 'GFUtil.alpha(target, %.1f)' % params.get_float("target_alpha", 0.0)
		"freeze_frame":
			code = 'GFUtil.freeze(%.2f)' % params.get_float("duration", 0.05)
		"time_scale":
			code = 'GFUtil.slow_motion(%.1f, %.1f)' % [params.get_float("duration", 1.0), params.get_float("scale", 0.3)]
		"hit_light":
			code = 'GFUtil.hit(target, %.1f)' % params.get_float("intensity", 1.0)
		"hit_heavy":
			code = 'GFUtil.hit_heavy(target, %.1f)' % params.get_float("intensity", 1.0)
		"death":
			code = 'GFUtil.death(target, %.1f)' % params.get_float("intensity", 1.0)
		"pickup":
			code = 'GFUtil.pickup(target, %.1f)' % params.get_float("intensity", 1.0)
		"explosion":
			code = 'GFUtil.explosion(target, %.1f)' % params.get_float("intensity", 1.0)
		_:
			code = '# Select an effect'
	
	if code_label:
		code_label.text = code
