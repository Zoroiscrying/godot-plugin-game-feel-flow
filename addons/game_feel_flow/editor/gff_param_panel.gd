@tool
class_name GFFParamPanel
extends VBoxContainer

## Game Feel Flow Parameter Panel
## Right panel: show and edit selected Block's parameters

# ===== Signals =====
signal param_changed(effect: GFFEffect, param_name: String, value: Variant)
signal clone_requested()
signal save_as_tres_requested()
signal preview_requested(effect: GFFEffect)

# ===== Private =====
var _current_effect: GFFEffect = null
var _is_reference: bool = false

# ===== Public Methods =====

func show_effect(effect: GFFEffect, is_reference: bool, display_name: String) -> void:
	_current_effect = effect
	_is_reference = is_reference
	_clear_params()
	
	if not effect:
		var empty = Label.new()
		empty.text = "No effect selected"
		empty.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
		add_child(empty)
		return
	
	# Header
	var header = HBoxContainer.new()
	var title = Label.new()
	title.text = display_name
	title.add_theme_font_size_override("font_size", 14)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	add_child(header)
	
	if is_reference:
		var ref_label = Label.new()
		ref_label.text = "🔒 Reference (read-only)"
		ref_label.add_theme_color_override("font_color", Color(0.95, 0.88, 0.6))
		add_child(ref_label)
	
	# Common params
	_add_separator()
	_add_header("Common")
	
	if _is_event_effect(effect):
		# Event blocks: zero-duration markers, no intensity/duration to edit
		var info = Label.new()
		info.text = "Event marker — fires at block start time"
		info.add_theme_color_override("font_color", Color(0.65, 0.65, 0.70))
		add_child(info)
	else:
		_add_float_param(effect, "intensity", "Intensity", effect._get_default_intensity() if effect.has_method("_get_default_intensity") else 1.0, 0.0, 5.0, not is_reference)
		_add_float_param(effect, "duration", "Duration", effect.duration, 0.01, 5.0, not is_reference)
	
	# Effect-specific params
	_add_separator()
	_add_header("Effect Parameters")
	
	if _is_event_effect(effect):
		_add_event_params(effect, not is_reference)
	elif effect is GFFEffectCommon:
		_add_curved_params(effect, is_reference)
	else:
		_add_params_from_config(effect, is_reference)
	
	# Action buttons
	_add_separator()
	var btn_row = HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 6)
	
	var preview_btn = Button.new()
	preview_btn.text = "▶ Preview"
	preview_btn.pressed.connect(func(): preview_requested.emit(_current_effect))
	btn_row.add_child(preview_btn)
	
	if is_reference:
		var clone_btn = Button.new()
		clone_btn.text = "♻ Clone"
		clone_btn.pressed.connect(func(): clone_requested.emit())
		btn_row.add_child(clone_btn)
	else:
		var save_btn = Button.new()
		save_btn.text = "💾 Save As .tres"
		save_btn.pressed.connect(func(): save_as_tres_requested.emit())
		btn_row.add_child(save_btn)
	
	add_child(btn_row)

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

func _add_header(text: String) -> void:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85))
	add_child(label)

func _add_separator() -> void:
	var sep = HSeparator.new()
	sep.custom_minimum_size.y = 8
	add_child(sep)

func _is_event_effect(effect: GFFEffect) -> bool:
	## Duck-typed check for Pro's GFFEventEffect (method/signal event marker).
	## Avoids a hard class reference so the free addon works without Pro installed.
	return "event_type" in effect and "method_name" in effect and "signal_name" in effect

func _add_event_params(effect: GFFEffect, editable: bool) -> void:
	## Parameter UI for event blocks: event_type / method_name / signal_name / args
	# Event type selector
	var type_row = HBoxContainer.new()
	type_row.set_meta("param_name", "event_type")
	type_row.set_meta("param_type", "string")
	var type_label = Label.new()
	type_label.text = "Event Type:"
	type_label.custom_minimum_size.x = 100
	type_row.add_child(type_label)
	var type_option = OptionButton.new()
	type_option.name = "OptionButton"
	type_option.add_item("method")
	type_option.add_item("signal")
	type_option.selected = 1 if effect.get("event_type") == "signal" else 0
	type_option.disabled = not editable
	type_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	type_option.item_selected.connect(func(idx):
		param_changed.emit(effect, "event_type", type_option.get_item_text(idx))
	)
	type_row.add_child(type_option)
	add_child(type_row)
	
	_add_string_param(effect, "method_name", "Method Name", effect.get("method_name"), editable)
	_add_string_param(effect, "signal_name", "Signal Name", effect.get("signal_name"), editable)
	_add_string_param(effect, "args", "Args (comma-sep)", _args_to_text(effect.get("args")), editable)

func _add_string_param(effect: GFFEffect, name: String, display: String, current: String, editable: bool) -> void:
	var hbox = HBoxContainer.new()
	hbox.name = name
	hbox.set_meta("param_name", name)
	hbox.set_meta("param_type", "string")
	
	var label = Label.new()
	label.text = display + ":"
	label.custom_minimum_size.x = 100
	hbox.add_child(label)
	
	var edit = LineEdit.new()
	edit.name = "LineEdit"
	edit.text = current
	edit.editable = editable
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(edit)
	
	# Commit on Enter / focus loss (not per keystroke) because the editor
	# rebuilds this panel on every param_changed, which would steal focus.
	if name == "args":
		edit.text_submitted.connect(func(text):
			param_changed.emit(effect, name, _parse_args_text(text))
		)
		edit.focus_exited.connect(func():
			param_changed.emit(effect, name, _parse_args_text(edit.text))
		)
	else:
		edit.text_submitted.connect(func(text):
			param_changed.emit(effect, name, text)
		)
		edit.focus_exited.connect(func():
			param_changed.emit(effect, name, edit.text)
		)
	
	add_child(hbox)

func _args_to_text(args: Variant) -> String:
	if args is Array:
		var parts: Array = []
		for a in args:
			parts.append(str(a))
		return ", ".join(parts)
	return ""

func _parse_args_text(text: String) -> Array:
	## Parse "1, 2.5, hello" into [1, 2.5, "hello"] (numbers become floats)
	var result: Array = []
	for part in text.split(",", false):
		var p = part.strip_edges()
		if p.is_empty():
			continue
		if p.is_valid_float():
			result.append(p.to_float())
		else:
			result.append(p)
	return result

func _add_curved_params(effect: GFFEffectCommon, editable: bool) -> void:
	var target_name := ""
	var tweener_name := ""
	if effect.target:
		target_name = effect.target.get_target_name()
	if effect.tweener:
		tweener_name = effect.tweener.get_tweener_name()
	
	var info := Label.new()
	info.text = "Target: %s | Tweener: %s" % [target_name, tweener_name]
	info.add_theme_color_override("font_color", Color(0.65, 0.65, 0.70))
	add_child(info)

func _add_params_from_config(effect: GFFEffect, editable: bool) -> void:
	var config_script = load("res://addons/game_feel_flow/core/gff_effect_config_manager.gd")
	if not config_script:
		return
	
	var script = effect.get_script()
	var effect_name = ""
	if script and script is GDScript:
		effect_name = script.resource_path.get_file().get_basename().replace("gff_", "")
	
	var configs = config_script.get_config(effect_name)
	if configs.is_empty():
		var fallback = Label.new()
		fallback.text = "No editable parameters"
		fallback.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
		add_child(fallback)
		return
	
	for config in configs:
		if config is Resource:
			var param_type = config.get("param_type")
			var param_name = config.get("name")
			var display_name = config.get("display_name")
			var default_value = config.get("default_value")
			var min_value = config.get("min_value")
			var max_value = config.get("max_value")
			
			if param_type == null or param_name == null:
				continue
			
			# Read from effect's current value; fall back to default
			var current_value = effect.get(param_name) if param_name in effect else default_value
			
			match param_type:
				0:  # FLOAT
					_add_float_param(effect, param_name, display_name, current_value, min_value, max_value, editable)
				1:  # INT
					_add_int_param(effect, param_name, display_name, current_value, min_value, max_value, editable)
				2:  # BOOL
					_add_bool_param(effect, param_name, display_name, current_value, editable)
				4:  # COLOR
					_add_color_param(effect, param_name, display_name, current_value, editable)

func _add_float_param(effect: GFFEffect, name: String, display: String, default: float, min_val: float, max_val: float, editable: bool) -> void:
	var hbox = HBoxContainer.new()
	hbox.name = name
	hbox.set_meta("param_name", name)
	hbox.set_meta("param_type", "float")
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var label = Label.new()
	label.text = display + ":"
	label.custom_minimum_size.x = 100
	label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	hbox.add_child(label)

	var slider = HSlider.new()
	slider.name = "Slider"
	slider.min_value = min_val
	slider.max_value = max_val
	slider.step = 0.01
	slider.value = default
	slider.editable = editable
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.custom_minimum_size.x = 100
	hbox.add_child(slider)

	var spinbox = SpinBox.new()
	spinbox.name = "SpinBox"
	spinbox.min_value = min_val
	spinbox.max_value = max_val
	spinbox.step = 0.01
	spinbox.value = default
	spinbox.editable = editable
	spinbox.custom_minimum_size.x = 80
	spinbox.size_flags_horizontal = Control.SIZE_SHRINK_END
	hbox.add_child(spinbox)

	slider.value_changed.connect(func(v):
		spinbox.value = v
		param_changed.emit(effect, name, v)
	)
	spinbox.value_changed.connect(func(v):
		slider.value = v
		param_changed.emit(effect, name, v)
	)

	add_child(hbox)

func _add_int_param(effect: GFFEffect, name: String, display: String, default: int, min_val: int, max_val: int, editable: bool) -> void:
	var hbox = HBoxContainer.new()
	hbox.name = name
	hbox.set_meta("param_name", name)
	hbox.set_meta("param_type", "int")

	var label = Label.new()
	label.text = display + ":"
	label.custom_minimum_size.x = 100
	hbox.add_child(label)

	var spinbox = SpinBox.new()
	spinbox.name = "SpinBox"
	spinbox.min_value = min_val
	spinbox.max_value = max_val
	spinbox.step = 1
	spinbox.value = default
	spinbox.editable = editable
	spinbox.custom_minimum_size.x = 80
	spinbox.value_changed.connect(func(v): param_changed.emit(effect, name, int(v)))
	hbox.add_child(spinbox)

	add_child(hbox)

func _add_bool_param(effect: GFFEffect, name: String, display: String, default: bool, editable: bool) -> void:
	var hbox = HBoxContainer.new()
	hbox.name = name
	hbox.set_meta("param_name", name)
	hbox.set_meta("param_type", "bool")

	var checkbox = CheckBox.new()
	checkbox.name = "CheckBox"
	checkbox.text = display
	checkbox.button_pressed = default
	checkbox.disabled = not editable
	checkbox.toggled.connect(func(v): param_changed.emit(effect, name, v))
	hbox.add_child(checkbox)

	add_child(hbox)

func _add_color_param(effect: GFFEffect, name: String, display: String, default: Color, editable: bool) -> void:
	var hbox = HBoxContainer.new()
	hbox.name = name
	hbox.set_meta("param_name", name)
	hbox.set_meta("param_type", "color")

	var label = Label.new()
	label.text = display + ":"
	label.custom_minimum_size.x = 100
	hbox.add_child(label)

	var picker = ColorPickerButton.new()
	picker.name = "ColorPicker"
	picker.color = default
	picker.disabled = not editable
	picker.custom_minimum_size.x = 80
	picker.color_changed.connect(func(c): param_changed.emit(effect, name, c))
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
