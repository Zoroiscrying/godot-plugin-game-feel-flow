@tool
extends VBoxContainer

## Referencing ProtonScatter's parameter row layout: Label stretches on the left, editor fixed width on the right

signal value_changed(property_path: String, value: Variant, previous: Variant)

const CurveEditor := preload("res://addons/game_feel_flow/editor/ui/curve_editor.gd")

const META_EXPANDED_GROUPS := &"_gff_expanded_groups"

var _effect: GFFEffect = null
var _group_headers: Dictionary[String, Button] = {}
var _group_resources: Dictionary[String, Resource] = {}
var _group_properties: Dictionary[String, Array] = {}
var _ignore_list := [
	"enabled",
	"label",
	"priority",
	"overlap_strategy",
	"max_concurrent",
	"restore_after_play",
	"cooldown",
	"delay",
	"resource_path",
	"resource_name",
	"resource_local_to_scene",
	"script",
	"Script",
]

func set_effect(effect: GFFEffect) -> void:
	_effect = effect
	custom_minimum_size = Vector2(0, 100)
	if not value_changed.is_connected(_on_value_changed):
		value_changed.connect(_on_value_changed)
	_rebuild()

func _rebuild() -> void:
	var expanded_groups := _load_expanded_groups()

	_group_headers.clear()
	_group_resources.clear()
	_group_properties.clear()

	for child in get_children():
		child.queue_free()

	if _effect == null:
		return

	var current_group: VBoxContainer = self
	var current_group_name: String = ""
	for prop in _effect.get_property_list():
		# Only render @export_group (PROPERTY_USAGE_GROUP), filter base class category/subgroup
		if prop.usage & PROPERTY_USAGE_GROUP:
			if _is_builtin_group(prop.name):
				current_group = self
				current_group_name = ""
				continue
			# For GFFEffectCommon, keep the small common properties flat at the top.
			if _effect is GFFEffectCommon and prop.name == "Common Effect":
				current_group = self
				current_group_name = ""
				continue
			var group := _create_group(prop.name)
			current_group = group.get_meta("content") as VBoxContainer
			current_group_name = prop.name
			_group_properties[current_group_name] = []
			add_child(group)
			var header := group.get_meta("header") as Button
			if header:
				_group_headers[prop.name] = header
			continue
		if prop.usage & (PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SUBGROUP):
			continue
		if not (prop.usage & PROPERTY_USAGE_EDITOR):
			continue
		if prop.name in _ignore_list:
			continue
		if prop.name.begins_with("_"):
			continue

		# Full-width help block (not a cramped Label + LineEdit row).
		if prop.name == "custom_restore_help":
			var help := _create_help_block(str(_effect.get(prop.name)))
			current_group.add_child(help)
			if not current_group_name.is_empty():
				_group_properties[current_group_name].append(prop.name)
			continue

		var row = _create_property_row(prop)
		if row:
			current_group.add_child(row)
			if not current_group_name.is_empty():
				_group_properties[current_group_name].append(prop.name)

		if _effect is GFFEffectCommon:
			var common := _effect as GFFEffectCommon
			if prop.name == "target":
				_build_nested_resource_params(common.target, "Target Settings", "target")
			elif prop.name == "tweener":
				_build_nested_resource_params(common.tweener, "Tweener Settings", "tweener")

	# Restore expanded groups.
	for child in get_children():
		if child.has_meta("group_name") and child.get_meta("group_name") in expanded_groups:
			_expand_group(child)

	# Show a warning if the current target/tweener combination is incompatible.
	if _effect is GFFEffectCommon:
		var common := _effect as GFFEffectCommon
		if common.target and common.tweener and not common.tweener.can_handle(common.target):
			var warning := Label.new()
			warning.text = "Tweener does not support this target's value type."
			warning.add_theme_color_override("font_color", Color(0.95, 0.4, 0.3))
			warning.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			add_child(warning)

	_update_all_headers()

	# Place priority at the very bottom; it is a meta/runtime property and should
	# not sit between core effect groups in the combo editor.
	_add_priority_row()

func _add_priority_row() -> void:
	if _effect == null:
		return
	for prop in _effect.get_property_list():
		if prop.name == "priority":
			var row := _create_property_row(prop)
			if row:
				add_child(row)
			return

func _is_builtin_group(name: String) -> bool:
	if name in ["Resource", "Ref Counted", "script"]:
		return true
	if name.ends_with(".gd"):
		return true
	return false

func _create_group(group_name: String) -> VBoxContainer:
	var group := VBoxContainer.new()
	group.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	group.add_theme_constant_override("separation", 0)

	var header := Button.new()
	header.text = "  " + group_name.replace("_", " ").capitalize()
	header.tooltip_text = group_name.replace("_", " ").capitalize()
	header.alignment = HORIZONTAL_ALIGNMENT_LEFT
	header.flat = true
	header.icon = _get_icon("GuiTreeArrowRight")
	header.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	header.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	header.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	header.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	header.add_theme_color_override("font_color", Color(0.85, 0.87, 0.9))
	header.focus_mode = Control.FOCUS_NONE
	group.add_child(header)

	var content_margin := MarginContainer.new()
	content_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_margin.add_theme_constant_override("margin_left", 22)
	content_margin.visible = false

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 6)
	content_margin.add_child(content)
	group.add_child(content_margin)
	group.set_meta("content", content)
	group.set_meta("content_margin", content_margin)
	group.set_meta("header", header)
	group.set_meta("group_name", group_name)

	var sep := HSeparator.new()
	sep.modulate = Color(1, 1, 1, 0.3)
	sep.visible = false
	group.add_child(sep)
	group.set_meta("separator", sep)

	header.pressed.connect(func():
		content_margin.visible = not content_margin.visible
		header.icon = _get_icon("GuiTreeArrowDown") if content_margin.visible else _get_icon("GuiTreeArrowRight")
		sep.visible = content_margin.visible
		_save_expanded_groups()
	)

	return group

func _expand_group(group: VBoxContainer) -> void:
	var content_margin := group.get_meta("content_margin") as Control
	var header := group.get_meta("header") as Button
	var sep := group.get_meta("separator") as Control
	if content_margin:
		content_margin.visible = true
	if header:
		header.icon = _get_icon("GuiTreeArrowDown")
	if sep:
		sep.visible = true

func _save_expanded_groups() -> void:
	if _effect == null:
		return
	var expanded: Array[String] = []
	for child in get_children():
		if child.has_meta("group_name"):
			var content_margin := child.get_meta("content_margin") as Control
			if content_margin and content_margin.visible:
				expanded.append(child.get_meta("group_name"))
	_effect.set_meta(META_EXPANDED_GROUPS, expanded)

func _load_expanded_groups() -> Array[String]:
	if _effect == null:
		return []
	var raw := _effect.get_meta(META_EXPANDED_GROUPS, [])
	if raw is Array[String]:
		return raw
	if raw is Array:
		var result: Array[String] = []
		for item in raw:
			if item is String:
				result.append(item)
		return result
	return []

func _on_value_changed(property_path: String, _value: Variant, _previous: Variant) -> void:
	# restore_mode toggles which Restore fields are editor-visible — rebuild the form.
	if property_path == "restore_mode" or property_path.ends_with(":restore_mode"):
		_rebuild()
		return
	_update_all_headers()

func _update_all_headers() -> void:
	if _effect == null:
		return
	var known_groups: Array[String] = [
		"Common Effect", "Target Settings", "Tweener Settings",
		"Timing", "Restore", "Looping", "Randomness", "Curve",
	]
	_set_header_summary("Common Effect", _build_common_effect_summary())
	_set_header_summary("Target Settings", _build_target_settings_summary())
	_set_header_summary("Tweener Settings", _build_tweener_settings_summary())
	_set_header_summary("Timing", _build_timing_summary())
	_set_header_summary("Restore", _build_restore_summary())
	_set_header_summary("Looping", _build_looping_summary())
	_set_header_summary("Randomness", _build_randomness_summary())
	_set_header_summary("Curve", _build_curve_summary())
	# Generic fallback for effect-specific groups.
	for group_name in _group_headers.keys():
		if group_name in known_groups:
			continue
		_set_header_summary(group_name, _build_generic_group_summary(group_name))

func _set_header_summary(group_name: String, summary: String) -> void:
	var header := _group_headers.get(group_name) as Button
	if header == null:
		return
	var base_name := "  " + group_name.replace("_", " ").capitalize()
	if summary.is_empty():
		header.text = base_name
	else:
		header.text = "%s (%s)" % [base_name, summary]

func _build_common_effect_summary() -> String:
	if not _effect is GFFEffectCommon:
		return ""
	var common := _effect as GFFEffectCommon
	var target_name := ""
	var tweener_name := ""
	if common.target:
		target_name = common.target.get_target_name()
	if common.tweener:
		tweener_name = common.tweener.get_tweener_name()
	if target_name.is_empty() and tweener_name.is_empty():
		return "None"
	return "%s → %s" % [target_name if not target_name.is_empty() else "?", tweener_name if not tweener_name.is_empty() else "?"]

func _build_target_settings_summary() -> String:
	var resource := _group_resources.get("Target Settings") as Resource
	if resource == null:
		return "None"
	var parts: Array[String] = []
	if resource.get("mode") != null:
		parts.append(_format_mode(resource.get("mode"), ["To Target", "By Amount", "From Target"]))
	if resource.get("target_value") != null:
		var value_text := _format_variant(resource.get("target_value"))
		if resource.get("use_degrees") != null and resource.get("use_degrees"):
			value_text += "°"
		parts.append(value_text)
	if resource.get("target_color") != null:
		parts.append(_format_color(resource.get("target_color")))
	if resource.get("target_alpha") != null:
		parts.append("α %.2f" % float(resource.get("target_alpha")))
	return ", ".join(parts)

func _build_tweener_settings_summary() -> String:
	var resource := _group_resources.get("Tweener Settings") as Resource
	if resource == null:
		return "None"
	var name := ""
	if resource.has_method("get_tweener_name"):
		name = resource.get_tweener_name()
	if name.is_empty():
		name = resource.get_class().replace("GFF", "")
	var parts: Array[String] = [name]
	if resource.get("punch_mode") != null:
		parts.append(_format_mode(resource.get("punch_mode"), ["To Target", "To Origin"]))
	if resource.get("elasticity") != null:
		parts.append("el %.1f" % float(resource.get("elasticity")))
	if resource.get("flash_color") != null:
		parts.append(_format_color(resource.get("flash_color")))
	if resource.get("frequency") != null:
		parts.append("%.0f Hz" % float(resource.get("frequency")))
	if resource.get("amplitude") != null:
		parts.append("amp %.1f" % float(resource.get("amplitude")))
	if resource.get("lerp_mode") != null:
		parts.append(_format_mode(resource.get("lerp_mode"), ["Instant", "Linear", "Smooth"]))
	return ", ".join(parts)

func _build_timing_summary() -> String:
	if _effect == null:
		return ""
	var parts: Array[String] = ["%.2fs" % _effect.duration]
	if _effect.delay > 0.0:
		parts.append("delay %.2fs" % _effect.delay)
	if _effect.cooldown > 0.0:
		parts.append("cd %.2fs" % _effect.cooldown)
	return ", ".join(parts)

func _build_restore_summary() -> String:
	if _effect == null:
		return ""
	if not _effect.restore_after_play:
		return "Off"
	var mode := "Immediate"
	match _effect.restore_mode:
		GFFEffect.RestoreMode.IMMEDIATE:
			mode = "Immediate"
		GFFEffect.RestoreMode.GRADUAL:
			mode = "Gradual %.2fs" % _effect.restore_duration
		GFFEffect.RestoreMode.CUSTOM:
			mode = "Custom %.2fs" % _effect.restore_duration
	return "On, %s" % mode

func _build_looping_summary() -> String:
	if _effect == null:
		return ""
	var parts: Array[String] = []
	if _effect.loop_count == -1:
		parts.append("Forever")
	elif _effect.loop_count > 0:
		parts.append("%dx" % (_effect.loop_count + 1))
	else:
		return "Once"
	match _effect.loop_mode:
		GFFEffect.LoopMode.REPEAT:
			parts.append("Repeat")
		GFFEffect.LoopMode.PING_PONG:
			parts.append("PingPong")
		GFFEffect.LoopMode.MIRROR:
			parts.append("Mirror")
	if _effect.loop_delay > 0.0:
		parts.append("%.1fs delay" % _effect.loop_delay)
	if _effect.restore_between_loops:
		parts.append("restore each")
	return ", ".join(parts)

func _build_randomness_summary() -> String:
	if _effect == null:
		return ""
	var dur_min: float = _effect.random_duration_min
	var dur_max: float = _effect.random_duration_max
	var int_min: float = _effect.random_intensity_min
	var int_max: float = _effect.random_intensity_max
	if dur_min == 1.0 and dur_max == 1.0 and int_min == 1.0 and int_max == 1.0:
		return ""
	var parts: Array[String] = []
	if dur_min != 1.0 or dur_max != 1.0:
		parts.append("Duration %s" % _format_range(dur_min, dur_max))
	if int_min != 1.0 or int_max != 1.0:
		parts.append("Intensity %s" % _format_range(int_min, int_max))
	return ", ".join(parts)

func _build_curve_summary() -> String:
	if _effect == null:
		return ""
	if _effect.easing_curve == null:
		return ""
	return "Custom"

func _build_generic_group_summary(group_name: String) -> String:
	if _effect == null:
		return ""
	var props: Array = _group_properties.get(group_name, [])
	if props.is_empty():
		return ""
	var parts: Array[String] = []
	for prop_name: String in props:
		if prop_name in _ignore_list:
			continue
		var value = _effect.get(prop_name)
		if value == null:
			continue
		if value is Resource:
			continue
		if value is String and value.is_empty():
			continue
		# Skip default/zero/uninteresting values.
		if value is bool and not value:
			continue
		if value is float and is_equal_approx(value, 0.0):
			continue
		if value is int and value == 0:
			continue
		if value is Vector3 and value == Vector3.ZERO:
			continue
		if value is Vector2 and value == Vector2.ZERO:
			continue
		if value is Color and value == Color.WHITE:
			continue
		var label := prop_name.replace("_", " ").capitalize()
		parts.append("%s %s" % [label, _format_variant(value)])
		if parts.size() >= 2:
			break
	return ", ".join(parts)

func _format_mode(value: Variant, labels: PackedStringArray = []) -> String:
	if value is int and value >= 0 and value < labels.size():
		return labels[value]
	return str(value)

func _format_variant(value: Variant) -> String:
	if value is Vector3:
		return "(%.2f, %.2f, %.2f)" % [value.x, value.y, value.z]
	if value is Vector2:
		return "(%.2f, %.2f)" % [value.x, value.y]
	if value is Color:
		return _format_color(value)
	if value is float:
		return "%.2f" % value
	if value is int:
		return str(value)
	return str(value)

func _format_color(c: Color) -> String:
	return "#%s" % c.to_html(true)

func _format_range(min_val: float, max_val: float) -> String:
	if abs(min_val - max_val) < 0.001:
		return "%.2f" % min_val
	return "%.2f-%.2f" % [min_val, max_val]

func _get_icon(name: String) -> Texture2D:
	if Engine.is_editor_hint():
		return EditorInterface.get_editor_theme().get_icon(name, "EditorIcons")
	return null

func _create_property_row(prop: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.custom_minimum_size = Vector2(0, 28)
	row.add_theme_constant_override("separation", 8)

	var label := Label.new()
	label.text = prop.name.replace("_", " ").capitalize()
	label.tooltip_text = label.text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_stretch_ratio = 1.0
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(label)

	var editor := _create_editor_for_property(prop)
	if editor == null:
		return null

	editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	editor.size_flags_stretch_ratio = 1.618
	editor.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_set_tooltip_recursive(editor, label.text)
	row.add_child(editor)
	row.tooltip_text = label.text
	return row

func _set_tooltip_recursive(control: Control, text: String) -> void:
	control.tooltip_text = text
	for child in control.get_children():
		if child is Control:
			_set_tooltip_recursive(child, text)

func _create_editor_for_property(prop: Dictionary) -> Control:
	var current_value = _effect.get(prop.name)

	match prop.type:
		TYPE_BOOL:
			var cb := CheckBox.new()
			cb.button_pressed = current_value
			cb.toggled.connect(func(v):
				value_changed.emit(prop.name, v, _effect.get(prop.name))
				_effect.set(prop.name, v)
			)
			return cb

		TYPE_INT:
			if prop.hint == PROPERTY_HINT_ENUM:
				return _create_enum_editor(prop, current_value)
			var spin := _create_spinbox(prop, false)
			spin.value = current_value
			spin.value_changed.connect(func(v):
				value_changed.emit(prop.name, int(v), _effect.get(prop.name))
				_effect.set(prop.name, int(v))
			)
			return spin

		TYPE_FLOAT:
			var spin := _create_spinbox(prop, true)
			spin.value = current_value
			spin.value_changed.connect(func(v):
				value_changed.emit(prop.name, v, _effect.get(prop.name))
				_effect.set(prop.name, v)
			)
			return spin

		TYPE_STRING:
			if prop.hint == PROPERTY_HINT_MULTILINE_TEXT:
				return _create_multiline_string_editor(prop, str(current_value))
			var line := LineEdit.new()
			line.text = current_value
			line.custom_minimum_size = Vector2(120, 0)
			line.text_changed.connect(func(v):
				value_changed.emit(prop.name, v, _effect.get(prop.name))
				_effect.set(prop.name, v)
			)
			return line

		TYPE_COLOR:
			var picker := ColorPickerButton.new()
			picker.color = current_value
			picker.custom_minimum_size = Vector2(80, 26)
			picker.color_changed.connect(func(v):
				value_changed.emit(prop.name, v, _effect.get(prop.name))
				_effect.set(prop.name, v)
			)
			return picker

		TYPE_VECTOR2:
			return _create_vector_editor(2, prop.name, current_value)

		TYPE_VECTOR3:
			return _create_vector_editor(3, prop.name, current_value)

		TYPE_OBJECT:
			if prop.class_name == &"Curve" or prop.hint_string == "Curve":
				return _create_curve_editor(prop, current_value)
			var base_type: String
			if prop.class_name:
				base_type = prop.class_name
			else:
				base_type = prop.hint_string
			return _create_resource_editor(prop, current_value, base_type)

		TYPE_DICTIONARY:
			return _create_dictionary_editor(prop, current_value)

		TYPE_ARRAY:
			return _create_array_editor(prop, current_value)

		TYPE_NIL:
			return _create_variant_editor(prop, current_value)

	return null

func _create_curve_preset(preset: String) -> Curve:
	var c := Curve.new()
	match preset:
		"linear":
			c.add_point(Vector2(0, 0))
			c.add_point(Vector2(1, 1))
		"ease_in":
			c.add_point(Vector2(0, 0), 0.0, 0.0)
			c.add_point(Vector2(1, 1), 2.5, 0.0)
		"ease_out":
			c.add_point(Vector2(0, 0), 0.0, 2.5)
			c.add_point(Vector2(1, 1), 0.0, 0.0)
		"ease_in_out":
			c.add_point(Vector2(0, 0), 0.0, 0.0)
			c.add_point(Vector2(0.5, 0.5), 2.0, 2.0)
			c.add_point(Vector2(1, 1), 0.0, 0.0)
		"ease_out_in":
			c.add_point(Vector2(0, 0), 0.0, 2.5)
			c.add_point(Vector2(0.5, 0.5), 0.0, 0.0)
			c.add_point(Vector2(1, 1), 2.5, 0.0)
	return c

func _create_curve_editor(prop: Dictionary, current_value: Curve) -> VBoxContainer:
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 4)

	var editor := CurveEditor.new()
	editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	editor.curve = current_value
	editor.visible = (current_value != null)
	vbox.add_child(editor)

	var toolbar := HBoxContainer.new()
	toolbar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(toolbar)

	var hint := Label.new()
	hint.text = "X = time, Y = interpolation factor (0 = start value, 1 = end value)."
	hint.add_theme_color_override("font_color", Color(0.6, 0.6, 0.65))
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(hint)

	var no_curve_label := Label.new()
	no_curve_label.text = "No curve configured. Select a preset to create one."
	no_curve_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
	no_curve_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	no_curve_label.visible = (current_value == null)
	vbox.add_child(no_curve_label)

	var override_warning := Label.new()
	override_warning.text = "Curve overrides the Tweener's built-in easing."
	override_warning.add_theme_color_override("font_color", Color(0.95, 0.65, 0.25))
	override_warning.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	override_warning.visible = (_effect is GFFEffectCommon and (_effect as GFFEffectCommon).tweener != null and current_value != null)
	vbox.add_child(override_warning)

	var _update_curve_ui := func() -> void:
		var has_curve := (editor.curve != null)
		editor.visible = has_curve
		no_curve_label.visible = not has_curve
		override_warning.visible = (_effect is GFFEffectCommon and (_effect as GFFEffectCommon).tweener != null and has_curve)

	var _apply_curve := func(c: Curve) -> void:
		var prev = _effect.get(prop.name)
		editor.curve = c
		_update_curve_ui.call()
		value_changed.emit(prop.name, c, prev)
		_effect.set(prop.name, c)

	var preset_select := OptionButton.new()
	preset_select.custom_minimum_size = Vector2(120, 0)
	preset_select.add_item("Preset...")
	preset_select.set_item_metadata(0, "")
	var presets := {
		"Linear": "linear",
		"Ease In": "ease_in",
		"Ease Out": "ease_out",
		"Ease In-Out": "ease_in_out",
		"Ease Out-In": "ease_out_in",
	}
	for label in presets.keys():
		var idx := preset_select.item_count
		preset_select.add_item(label)
		preset_select.set_item_metadata(idx, presets[label])
	preset_select.item_selected.connect(func(idx: int):
		var key: String = preset_select.get_item_metadata(idx)
		if not key.is_empty():
			_apply_curve.call(_create_curve_preset(key))
		preset_select.selected = 0
	)
	toolbar.add_child(preset_select)

	var clear_btn := Button.new()
	clear_btn.text = "Clear"
	clear_btn.pressed.connect(func():
		var prev = _effect.get(prop.name)
		editor.curve = null
		_update_curve_ui.call()
		value_changed.emit(prop.name, null, prev)
		_effect.set(prop.name, null)
	)
	toolbar.add_child(clear_btn)

	editor.curve_changed.connect(func():
		_update_curve_ui.call()
		value_changed.emit(prop.name, editor.curve, null)
	)

	return vbox

func _create_spinbox(prop: Dictionary, is_float: bool) -> SpinBox:
	var spin := SpinBox.new()
	spin.custom_minimum_size = Vector2(90, 0)
	spin.min_value = -999999.0
	spin.max_value = 999999.0
	spin.step = 0.01 if is_float else 1.0
	spin.allow_greater = true
	spin.allow_lesser = true

	if prop.hint == PROPERTY_HINT_RANGE and prop.hint_string.contains(","):
		var parts: PackedStringArray = prop.hint_string.split(",")
		spin.min_value = float(parts[0])
		spin.max_value = float(parts[1])
		if parts.size() >= 3:
			spin.step = float(parts[2])
		spin.allow_greater = false
		spin.allow_lesser = false

	return spin

func _create_help_block(text: String) -> Control:
	## Full-width, wrapping help text for read-only guidance (e.g. Custom restore).
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size = Vector2(0, 0)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.14, 0.18, 0.95)
	style.set_corner_radius_all(4)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	style.border_color = Color(0.28, 0.32, 0.40, 0.8)
	style.set_border_width_all(1)
	panel.add_theme_stylebox_override("panel", style)

	var label := Label.new()
	label.text = text.strip_edges()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_color_override("font_color", Color(0.72, 0.78, 0.86))
	label.add_theme_font_size_override("font_size", 12)
	panel.add_child(label)
	return panel

func _create_multiline_string_editor(prop: Dictionary, current_value: String) -> Control:
	var edit := TextEdit.new()
	edit.text = current_value
	edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	edit.custom_minimum_size = Vector2(120, 140)
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	edit.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var read_only: bool = (prop.usage & PROPERTY_USAGE_READ_ONLY) != 0
	edit.editable = not read_only
	if not read_only:
		edit.text_changed.connect(func():
			value_changed.emit(prop.name, edit.text, _effect.get(prop.name))
			_effect.set(prop.name, edit.text)
		)
	return edit

func _create_enum_editor(prop: Dictionary, current_value: int) -> OptionButton:
	var select := OptionButton.new()
	select.custom_minimum_size = Vector2(120, 0)
	var items: PackedStringArray = prop.hint_string.split(",")
	for i in range(items.size()):
		var item_name := items[i]
		if item_name.contains(":"):
			item_name = item_name.split(":")[0]
		select.add_item(item_name, i)
	select.selected = current_value
	select.item_selected.connect(func(idx: int):
		var previous: Variant = _effect.get(prop.name)
		_effect.set(prop.name, idx)
		value_changed.emit(prop.name, idx, previous)
	)
	return select

func _create_vector_editor(dim: int, prop_name: String, current_value: Variant) -> HBoxContainer:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)

	for i in range(dim):
		var label := Label.new()
		label.text = ["X", "Y", "Z"][i]
		label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		hbox.add_child(label)

		var spin := SpinBox.new()
		spin.min_value = -999999.0
		spin.max_value = 999999.0
		spin.step = 0.01
		spin.value = current_value[i]
		spin.value_changed.connect(func(v):
			var vec = _effect.get(prop_name)
			var new_vec: Variant
			if vec is Vector3:
				new_vec = Vector3(vec.x, vec.y, vec.z)
			elif vec is Vector2:
				new_vec = Vector2(vec.x, vec.y)
			else:
				new_vec = vec
			new_vec[i] = v
			value_changed.emit(prop_name, new_vec, vec)
			_effect.set(prop_name, new_vec)
		)
		hbox.add_child(spin)

	return hbox

func _create_resource_editor(prop: Dictionary, current_value: Variant, base_type: String) -> Control:
	if base_type == "GFFTarget":
		return _create_sub_resource_selector(prop, current_value, GFFEffectRegistry.get_target_keys(), GFFEffectRegistry.get_target_script)
	if base_type == "GFFTweener":
		var value_type := -1
		if _effect is GFFEffectCommon and _effect.target != null:
			value_type = _effect.target.get_value_type()
		var tweener_keys := GFFEffectRegistry.get_tweener_keys_for_value_type(value_type)
		if tweener_keys.is_empty():
			tweener_keys = GFFEffectRegistry.get_tweener_keys()
		return _create_sub_resource_selector(prop, current_value, tweener_keys, GFFEffectRegistry.get_tweener_script)

	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 4)

	var line := LineEdit.new()
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.custom_minimum_size = Vector2(120, 0)
	line.editable = false
	line.text = _resource_display_path(current_value)
	row.add_child(line)

	var browse_btn := Button.new()
	browse_btn.text = "..."
	browse_btn.pressed.connect(_browse_resource.bind(line, prop.name, base_type))
	row.add_child(browse_btn)

	var clear_btn := Button.new()
	clear_btn.text = "Clear"
	clear_btn.pressed.connect(func():
		_set_resource(prop.name, null, line)
	)
	row.add_child(clear_btn)

	return row

func _create_sub_resource_selector(prop: Dictionary, current_value: Variant, keys: Array, script_getter: Callable) -> Control:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 4)

	var select := OptionButton.new()
	select.custom_minimum_size = Vector2(120, 0)
	select.add_item("None")
	select.set_item_metadata(0, "")

	var current_script: Script = current_value.get_script() if current_value is Resource else null
	var selected_index := 0
	for i in range(keys.size()):
		var key: String = keys[i]
		select.add_item(key.capitalize())
		var idx := select.item_count - 1
		select.set_item_metadata(idx, key)
		if current_script and current_script == script_getter.call(key):
			selected_index = idx
	select.selected = selected_index

	select.item_selected.connect(func(idx: int):
		var key: String = select.get_item_metadata(idx)
		var new_res: Resource = null
		if not key.is_empty():
			var script := script_getter.call(key) as Script
			if script:
				new_res = script.new()
		value_changed.emit(prop.name, new_res, _effect.get(prop.name))
		_effect.set(prop.name, new_res)
		_rebuild()
	)

	row.add_child(select)
	return row


func _resource_display_path(res: Variant) -> String:
	if res == null:
		return ""
	if res is Resource:
		return res.resource_path
	return str(res)


func _set_resource(prop_name: String, res: Variant, line: LineEdit) -> void:
	var prev := _effect.get(prop_name)
	value_changed.emit(prop_name, res, prev)
	_effect.set(prop_name, res)
	line.text = _resource_display_path(res)


func _browse_resource(line: LineEdit, prop_name: String, base_type: String) -> void:
	var dlg := FileDialog.new()
	dlg.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dlg.access = FileDialog.ACCESS_RESOURCES
	dlg.title = "Select " + base_type

	match base_type:
		"AudioStream":
			dlg.add_filter("*.wav,*.ogg,*.mp3", "AudioStream")
		"PackedScene":
			dlg.add_filter("*.tscn,*.scn", "PackedScene")
		"ParticleProcessMaterial":
			dlg.add_filter("*.tres", "ParticleProcessMaterial")
		"Curve":
			dlg.add_filter("*.tres", "Curve")
		_:
			dlg.add_filter("*", base_type)

	dlg.file_selected.connect(func(path: String):
		var res := load(path)
		_set_resource(prop_name, res, line)
		dlg.queue_free()
	)
	dlg.canceled.connect(func():
		dlg.queue_free()
	)
	add_child(dlg)
	dlg.popup_centered(Vector2(800, 500))


func _create_dictionary_editor(prop: Dictionary, current_value: Variant) -> Control:
	var line := LineEdit.new()
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.custom_minimum_size = Vector2(120, 0)
	line.text = var_to_str(current_value)
	line.focus_exited.connect(func():
		var parsed: Variant = str_to_var(line.text)
		if not parsed is Dictionary:
			line.text = var_to_str(_effect.get(prop.name))
			return
		var prev := _effect.get(prop.name)
		value_changed.emit(prop.name, parsed, prev)
		_effect.set(prop.name, parsed)
	)
	return line


func _create_array_editor(prop: Dictionary, current_value: Variant) -> Control:
	var line := LineEdit.new()
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.custom_minimum_size = Vector2(120, 0)
	line.text = var_to_str(current_value)
	line.focus_exited.connect(func():
		var parsed: Variant = str_to_var(line.text)
		if not parsed is Array:
			line.text = var_to_str(_effect.get(prop.name))
			return
		var prev := _effect.get(prop.name)
		value_changed.emit(prop.name, parsed, prev)
		_effect.set(prop.name, parsed)
	)
	return line


func _create_variant_editor(prop: Dictionary, current_value: Variant) -> Control:
	var line := LineEdit.new()
	line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.custom_minimum_size = Vector2(120, 0)
	line.text = var_to_str(current_value)
	line.focus_exited.connect(func():
		var parsed: Variant = str_to_var(line.text)
		var prev := _effect.get(prop.name)
		value_changed.emit(prop.name, parsed, prev)
		_effect.set(prop.name, parsed)
	)
	return line

func _build_nested_resource_params(resource: Resource, group_name: String, prefix: String) -> void:
	var group := _create_group(group_name)
	var header := group.get_meta("header") as Button
	if header:
		_group_headers[group_name] = header
	if resource == null:
		add_child(group)
		return
	_group_resources[group_name] = resource
	var content := group.get_meta("content") as VBoxContainer
	add_child(group)
	for prop in resource.get_property_list():
		if prop.usage & PROPERTY_USAGE_GROUP:
			continue
		if prop.usage & (PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SUBGROUP):
			continue
		if not (prop.usage & PROPERTY_USAGE_EDITOR):
			continue
		if prop.name in _ignore_list or prop.name.begins_with("_"):
			continue
		var row := _create_nested_property_row(resource, prop, prefix)
		if row:
			content.add_child(row)

func _create_nested_property_row(resource: Resource, prop: Dictionary, prefix: String) -> Control:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.custom_minimum_size = Vector2(0, 28)
	row.add_theme_constant_override("separation", 8)

	var label := Label.new()
	label.text = prop.name.replace("_", " ").capitalize()
	label.tooltip_text = label.text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_stretch_ratio = 1.0
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(label)

	var editor := _create_nested_editor(resource, prop, prefix)
	if editor == null:
		return null

	editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	editor.size_flags_stretch_ratio = 1.618
	editor.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_set_tooltip_recursive(editor, label.text)
	row.add_child(editor)
	row.tooltip_text = label.text
	return row

func _create_nested_editor(resource: Resource, prop: Dictionary, prefix: String) -> Control:
	var current_value = resource.get(prop.name)
	var prop_path: String = prefix + ":" + prop.name
	match prop.type:
		TYPE_BOOL:
			var cb := CheckBox.new()
			cb.button_pressed = current_value
			cb.toggled.connect(func(v):
				var prev = resource.get(prop.name)
				resource.set(prop.name, v)
				value_changed.emit(prop_path, v, prev)
			)
			return cb
		TYPE_INT:
			if prop.hint == PROPERTY_HINT_ENUM:
				return _create_nested_enum_editor(resource, prop, current_value, prefix)
			var spin := _create_spinbox(prop, false)
			spin.value = current_value
			spin.value_changed.connect(func(v):
				var prev = resource.get(prop.name)
				resource.set(prop.name, int(v))
				value_changed.emit(prop_path, int(v), prev)
			)
			return spin
		TYPE_FLOAT:
			var spin := _create_spinbox(prop, true)
			spin.value = current_value
			spin.value_changed.connect(func(v):
				var prev = resource.get(prop.name)
				resource.set(prop.name, v)
				value_changed.emit(prop_path, v, prev)
			)
			return spin
		TYPE_STRING:
			var line := LineEdit.new()
			line.text = current_value
			line.custom_minimum_size = Vector2(120, 0)
			line.text_changed.connect(func(v):
				var prev = resource.get(prop.name)
				resource.set(prop.name, v)
				value_changed.emit(prop_path, v, prev)
			)
			return line
		TYPE_COLOR:
			var picker := ColorPickerButton.new()
			picker.color = current_value
			picker.custom_minimum_size = Vector2(80, 26)
			picker.color_changed.connect(func(v):
				var prev = resource.get(prop.name)
				resource.set(prop.name, v)
				value_changed.emit(prop_path, v, prev)
			)
			return picker
		TYPE_VECTOR2:
			return _create_nested_vector_editor(resource, prop.name, current_value, 2, prefix)
		TYPE_VECTOR3:
			return _create_nested_vector_editor(resource, prop.name, current_value, 3, prefix)
	return null

func _create_nested_enum_editor(resource: Resource, prop: Dictionary, current_value: int, prefix: String) -> OptionButton:
	var select := OptionButton.new()
	select.custom_minimum_size = Vector2(120, 0)
	var items: PackedStringArray = prop.hint_string.split(",")
	for i in range(items.size()):
		var item_name := items[i]
		if item_name.contains(":"):
			item_name = item_name.split(":")[0]
		select.add_item(item_name, i)
	select.selected = current_value
	select.item_selected.connect(func(idx: int):
		var prev = resource.get(prop.name)
		resource.set(prop.name, idx)
		value_changed.emit(prefix + ":" + prop.name, idx, prev)
	)
	return select

func _create_nested_vector_editor(resource: Resource, prop_name: String, current_value: Variant, dim: int, prefix: String) -> HBoxContainer:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	for i in range(dim):
		var label := Label.new()
		label.text = ["X", "Y", "Z"][i]
		label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		hbox.add_child(label)
		var spin := SpinBox.new()
		spin.min_value = -999999.0
		spin.max_value = 999999.0
		spin.step = 0.01
		spin.value = current_value[i]
		spin.value_changed.connect(func(v):
			var vec = resource.get(prop_name)
			var new_vec: Variant
			if vec is Vector3:
				new_vec = Vector3(vec.x, vec.y, vec.z)
			elif vec is Vector2:
				new_vec = Vector2(vec.x, vec.y)
			else:
				new_vec = vec
			new_vec[i] = v
			resource.set(prop_name, new_vec)
			value_changed.emit(prefix + ":" + prop_name, new_vec, vec)
		)
		hbox.add_child(spin)
	return hbox
