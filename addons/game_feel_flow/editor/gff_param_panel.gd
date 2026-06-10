@tool
extends VBoxContainer

## Game Feel Flow Parameter Panel

# ===== Signals =====
signal param_changed(param_name: String, value: Variant)

# ===== Public Methods =====

func show_params(effect_name: String) -> void:
	_clear_params()

	# Get config from manager
	var config_script = load("res://addons/game_feel_flow/core/gff_effect_config_manager.gd")
	if config_script:
		var configs = config_script.get_config(effect_name)
		print("GFFParamPanel: Loading config for ", effect_name, " - found ", configs.size(), " configs")
		if configs.size() > 0:
			_add_params_from_config(configs)
			return
		else:
			print("GFFParamPanel: No config found for ", effect_name)

	# Fallback: add default params
	_add_default_params()

func get_params() -> Dictionary:
	var params = {}
	for child in get_children():
		if child is HBoxContainer and child.has_meta("param_name"):
			var name = child.get_meta("param_name")
			var value = _get_value(child)
			if value != null:
				params[name] = value
	return params

# ===== Internal Methods =====

func _clear_params() -> void:
	for child in get_children():
		child.queue_free()

func _add_default_params() -> void:
	_add_float_param("intensity", "Intensity", 1.0, 0.1, 5.0)
	_add_float_param("duration", "Duration", 0.5, 0.01, 2.0)

func _add_params_from_config(configs: Array) -> void:
	for config in configs:
		# Check if it's a GFFEffectConfig object
		if config is Resource:
			# Get properties using get() method
			var param_type = config.get("param_type")
			var param_name = config.get("name")
			var display_name = config.get("display_name")
			var default_value = config.get("default_value")
			var min_value = config.get("min_value")
			var max_value = config.get("max_value")

			if param_type != null and param_name != null:
				match param_type:
					0:  # FLOAT
						_add_float_param(param_name, display_name, default_value, min_value, max_value)
					1:  # INT
						_add_int_param(param_name, display_name, default_value, min_value, max_value)
					2:  # BOOL
						_add_bool_param(param_name, display_name, default_value)
					4:  # COLOR
						_add_color_param(param_name, display_name, default_value)

func _add_float_param(name: String, display: String, default: float, min_val: float, max_val: float) -> void:
	var hbox = HBoxContainer.new()
	hbox.name = name
	hbox.set_meta("param_name", name)
	hbox.set_meta("param_type", "float")
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Label
	var label = Label.new()
	label.text = display + ":"
	label.custom_minimum_size.x = 100
	label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	hbox.add_child(label)

	# Slider
	var slider = HSlider.new()
	slider.name = "Slider"
	slider.min_value = min_val
	slider.max_value = max_val
	slider.step = 0.01
	slider.value = default
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.custom_minimum_size.x = 100
	hbox.add_child(slider)

	# SpinBox
	var spinbox = SpinBox.new()
	spinbox.name = "SpinBox"
	spinbox.min_value = min_val
	spinbox.max_value = max_val
	spinbox.step = 0.01
	spinbox.value = default
	spinbox.custom_minimum_size.x = 80
	spinbox.size_flags_horizontal = Control.SIZE_SHRINK_END
	hbox.add_child(spinbox)

	# Sync slider and spinbox
	slider.value_changed.connect(func(v): spinbox.value = v)
	spinbox.value_changed.connect(func(v): slider.value = v)

	add_child(hbox)

func _add_int_param(name: String, display: String, default: int, min_val: int, max_val: int) -> void:
	var hbox = HBoxContainer.new()
	hbox.name = name
	hbox.set_meta("param_name", name)
	hbox.set_meta("param_type", "int")

	# Label
	var label = Label.new()
	label.text = display + ":"
	label.custom_minimum_size.x = 100
	hbox.add_child(label)

	# SpinBox
	var spinbox = SpinBox.new()
	spinbox.name = "SpinBox"
	spinbox.min_value = min_val
	spinbox.max_value = max_val
	spinbox.step = 1
	spinbox.value = default
	spinbox.custom_minimum_size.x = 80
	hbox.add_child(spinbox)

	add_child(hbox)

func _add_bool_param(name: String, display: String, default: bool) -> void:
	var hbox = HBoxContainer.new()
	hbox.name = name
	hbox.set_meta("param_name", name)
	hbox.set_meta("param_type", "bool")

	# Checkbox
	var checkbox = CheckBox.new()
	checkbox.name = "CheckBox"
	checkbox.text = display
	checkbox.button_pressed = default
	hbox.add_child(checkbox)

	add_child(hbox)

func _add_color_param(name: String, display: String, default: Color) -> void:
	var hbox = HBoxContainer.new()
	hbox.name = name
	hbox.set_meta("param_name", name)
	hbox.set_meta("param_type", "color")

	# Label
	var label = Label.new()
	label.text = display + ":"
	label.custom_minimum_size.x = 100
	hbox.add_child(label)

	# ColorPickerButton
	var picker = ColorPickerButton.new()
	picker.name = "ColorPicker"
	picker.color = default
	picker.custom_minimum_size.x = 80
	hbox.add_child(picker)

	add_child(hbox)

func _get_value(hbox: HBoxContainer):
	var type = hbox.get_meta("param_type", "float")
	match type:
		"float":
			var slider = hbox.get_node_or_null("Slider")
			if slider:
				return slider.value
			var spinbox = hbox.get_node_or_null("SpinBox")
			return spinbox.value if spinbox else 0.0
		"int":
			var spinbox = hbox.get_node_or_null("SpinBox")
			return int(spinbox.value) if spinbox else 0
		"bool":
			var checkbox = hbox.get_node_or_null("CheckBox")
			return checkbox.button_pressed if checkbox else false
		"color":
			var picker = hbox.get_node_or_null("ColorPicker")
			return picker.color if picker else Color.WHITE
	return null
