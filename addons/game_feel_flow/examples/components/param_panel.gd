extends VBoxContainer

## 参数面板组件
## 动态生成效果参数调节控件

# ===== 信号 =====
signal params_changed(params: GFFParams)

# ===== 属性 =====
var effect_name: String = ""
var params: Dictionary = {}

# ===== 节点引用 =====
var controls: Dictionary = {}

# ===== 公共方法 =====

func setup_for_effect(p_effect_name: String) -> void:
	effect_name = p_effect_name
	clear_controls()
	
	match p_effect_name:
		"shake":
			add_float_param("intensity", 1.0, 0.0, 3.0)
			add_float_param("duration", 0.1, 0.01, 0.5)
			add_float_param("amplitude", 2.0, 0.5, 10.0)
			add_float_param("frequency", 20.0, 5.0, 50.0)
		"scale":
			add_float_param("intensity", 1.0, 0.0, 3.0)
			add_float_param("duration", 0.1, 0.01, 0.5)
			add_float_param("target_scale", 1.1, 1.0, 2.0)
		"flash":
			add_float_param("intensity", 1.0, 0.0, 3.0)
			add_float_param("duration", 0.1, 0.01, 0.3)
			add_color_param("color", Color.WHITE)
		"color":
			add_float_param("intensity", 1.0, 0.0, 3.0)
			add_float_param("duration", 0.1, 0.01, 0.3)
			add_color_param("color", Color.RED)
		"alpha":
			add_float_param("intensity", 1.0, 0.0, 3.0)
			add_float_param("duration", 0.1, 0.01, 0.3)
		"freeze_frame":
			add_float_param("duration", 0.05, 0.01, 0.2)
		"time_scale":
			add_float_param("duration", 0.2, 0.01, 1.0)
			add_float_param("scale", 0.5, 0.1, 1.0)
		_:
			add_float_param("intensity", 1.0, 0.0, 3.0)
			add_float_param("duration", 0.1, 0.01, 0.5)

func get_params() -> GFFParams:
	var gff_params = GFFParams.new()
	for param_name in controls:
		var control = controls[param_name]
		if control is HSlider:
			if param_name == "intensity":
				gff_params.intensity = control.value
			elif param_name == "duration":
				gff_params.duration = control.value
			else:
				gff_params.with_float(param_name, control.value)
		elif control is ColorPickerButton:
			gff_params.with_color(param_name, control.color)
	return gff_params

func reset_params() -> void:
	setup_for_effect(effect_name)

# ===== 内部方法 =====

func clear_controls() -> void:
	for child in get_children():
		child.queue_free()
	controls.clear()

func add_float_param(param_name: String, default: float, min_val: float, max_val: float) -> void:
	var hbox = HBoxContainer.new()
	
	var label = Label.new()
	label.text = param_name.capitalize()
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
	
	slider.value_changed.connect(func(value): 
		value_label.text = "%.2f" % value
		params_changed.emit(get_params())
	)
	
	add_child(hbox)
	controls[param_name] = slider

func add_color_param(param_name: String, default: Color) -> void:
	var hbox = HBoxContainer.new()
	
	var label = Label.new()
	label.text = param_name.capitalize()
	label.custom_minimum_size.x = 100
	hbox.add_child(label)
	
	var color_picker = ColorPickerButton.new()
	color_picker.color = default
	color_picker.name = param_name
	hbox.add_child(color_picker)
	
	color_picker.color_changed.connect(func(color): 
		params_changed.emit(get_params())
	)
	
	add_child(hbox)
	controls[param_name] = color_picker
