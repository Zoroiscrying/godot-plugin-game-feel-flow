@tool
extends PanelContainer

## Single Effect Entry row (Unity Feel style)

signal toggled(enabled: bool)
signal deleted
signal moved(direction: int)
signal expand_toggled(is_expanded: bool)
signal entry_changed
signal effect_type_changed(entry: GFFComboEntry, new_path: String)
signal copy_requested(entry: GFFComboEntry)
signal paste_requested(entry: GFFComboEntry)
signal effect_property_changed(entry: GFFComboEntry, property_path: String, value: Variant, previous: Variant)
signal entry_property_changed(entry: GFFComboEntry, property: String, value: Variant, previous: Variant)

@export var entry: GFFComboEntry = null:
	set(v):
		entry = v
		_refresh()

@export var entry_index: int = 0
@export var category_color: Color = Color(0.4, 0.5, 0.7)
@export var is_expanded: bool = false:
	set(v):
		is_expanded = v
		_refresh()

const ROW_HEIGHT := 32

var _expand_btn: Button
var _params_container: Control
var _drag_handle: TextureRect = null
var _type_select: OptionButton = null

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	_refresh()

func _get_drag_data(at_position: Vector2) -> Variant:
	if _drag_handle == null:
		return null
	var handle_rect := Rect2(_drag_handle.global_position - global_position, _drag_handle.size)
	if not handle_rect.has_point(at_position):
		return null
	var preview := Label.new()
	preview.text = _effect_display_name()
	set_drag_preview(preview)
	return self

func _refresh() -> void:
	for child in get_children():
		child.queue_free()

	if entry == null or entry.effect == null:
		return

	custom_minimum_size = Vector2(0, ROW_HEIGHT)

	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(vbox)

	# Header row
	var header = HBoxContainer.new()
	header.add_theme_constant_override("separation", 6)
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(header)

	# Drag handle
	var drag_btn = TextureRect.new()
	drag_btn.texture = _get_icon("TripleBar")
	drag_btn.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	drag_btn.custom_minimum_size = Vector2(22, ROW_HEIGHT)
	drag_btn.tooltip_text = "Drag to reorder"
	drag_btn.mouse_default_cursor_shape = Control.CURSOR_DRAG
	drag_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header.add_child(drag_btn)
	_drag_handle = drag_btn

	# Effect icon
	var icon_tex := GFFIconManager.get_icon_for_effect(entry.effect)
	var icon := TextureRect.new()
	icon.texture = icon_tex
	icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	icon.custom_minimum_size = Vector2(ROW_HEIGHT, ROW_HEIGHT)
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header.add_child(icon)

	# Optional category color indicator
	var color_bar = ColorRect.new()
	color_bar.custom_minimum_size = Vector2(3, ROW_HEIGHT)
	color_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	color_bar.color = category_color
	header.add_child(color_bar)

	# Expand toggle
	_expand_btn = Button.new()
	_expand_btn.icon = _get_icon("GuiTreeArrowRight") if not is_expanded else _get_icon("GuiTreeArrowDown")
	_expand_btn.flat = true
	_expand_btn.custom_minimum_size = Vector2(22, ROW_HEIGHT)
	_expand_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_expand_btn.pressed.connect(_toggle_expand)
	header.add_child(_expand_btn)

	# Enable checkbox
	var enable_cb = CheckBox.new()
	enable_cb.button_pressed = entry.enabled
	enable_cb.tooltip_text = "Enable"
	enable_cb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	enable_cb.toggled.connect(func(v):
		var prev := entry.enabled
		entry_property_changed.emit(entry, "enabled", v, prev)
		toggled.emit(v)
	)
	header.add_child(enable_cb)

	# Effect type selector
	var type_select := OptionButton.new()
	var current_path := ""
	if entry.effect and entry.effect.get_script():
		current_path = entry.effect.get_script().get_path()
	var type_index := 0
	for type in GFFEffectTypeRegistry.get_effect_types():
		type_select.add_item(type.name)
		var idx := type_select.item_count - 1
		type_select.set_item_metadata(idx, type.path)
		var type_icon := GFFIconManager.get_icon_for_script_path(type.path)
		if type_icon:
			type_select.set_item_icon(idx, type_icon)
		if type.path == current_path:
			type_index = idx
	type_select.selected = type_index
	if entry.effect is GFFEffectCommon:
		type_select.text = _effect_display_name()
	_type_select = type_select
	type_select.fit_to_longest_item = false
	type_select.custom_minimum_size = Vector2(100, 0)
	type_select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	type_select.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	type_select.tooltip_text = "Change effect type"
	type_select.item_selected.connect(func(idx: int):
		var path: String = type_select.get_item_metadata(idx)
		if path != current_path:
			effect_type_changed.emit(entry, path)
	)
	header.add_child(type_select)

	# Track index (effects on different tracks run in parallel)
	var track_label := Label.new()
	track_label.text = "Track"
	track_label.add_theme_color_override("font_color", Color(0.65, 0.65, 0.70))
	track_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header.add_child(track_label)

	var track_spin := SpinBox.new()
	track_spin.min_value = 0
	track_spin.max_value = 99
	track_spin.step = 1
	track_spin.value = entry.track_idx
	track_spin.custom_minimum_size = Vector2(36, 0)
	track_spin.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	track_spin.tooltip_text = "Track index (different tracks run in parallel)"
	track_spin.value_changed.connect(func(v: float):
		var prev := entry.track_idx
		entry_property_changed.emit(entry, "track_idx", int(v), prev)
	)
	header.add_child(track_spin)

	# Time labels
	var time_label = Label.new()
	time_label.text = "%.2fs / %.2fs" % [entry.start_time, entry.duration]
	time_label.add_theme_color_override("font_color", Color(0.65, 0.65, 0.70))
	time_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	header.add_child(time_label)

	# Copy / Paste
	var can_paste := GFFEffectClipboard.can_paste(entry.effect)
	var copy_btn := Button.new()
	copy_btn.text = "Copy"
	copy_btn.flat = true
	copy_btn.custom_minimum_size = Vector2(40, ROW_HEIGHT)
	copy_btn.tooltip_text = "Copy effect parameters"
	copy_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	copy_btn.pressed.connect(func(): copy_requested.emit(entry))
	header.add_child(copy_btn)

	var paste_btn := Button.new()
	paste_btn.text = "Paste"
	paste_btn.flat = true
	paste_btn.custom_minimum_size = Vector2(40, ROW_HEIGHT)
	paste_btn.tooltip_text = "Paste effect parameters"
	paste_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	paste_btn.disabled = not can_paste
	paste_btn.pressed.connect(func(): paste_requested.emit(entry))
	header.add_child(paste_btn)

	# Delete
	var del_btn = Button.new()
	del_btn.icon = _get_icon("Remove")
	del_btn.flat = true
	del_btn.custom_minimum_size = Vector2(ROW_HEIGHT, ROW_HEIGHT)
	del_btn.tooltip_text = "Delete"
	del_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	del_btn.add_theme_color_override("icon_normal_color", Color(0.9, 0.3, 0.3))
	del_btn.pressed.connect(func(): deleted.emit())
	header.add_child(del_btn)

	# Parameters panel placeholder (created lazily when expanded)
	_params_container = MarginContainer.new()
	_params_container.visible = is_expanded
	_params_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_params_container.custom_minimum_size = Vector2(0, 100)
	_params_container.add_theme_constant_override("margin_left", 24)
	vbox.add_child(_params_container)

	if is_expanded:
		_build_params()

	_update_style()

func _build_params() -> void:
	if _params_container == null or entry == null or entry.effect == null:
		return
	if _params_container.get_child_count() > 0:
		return
	var params = preload("res://addons/game_feel_flow/editor/ui/effect_parameter_panel.tscn").instantiate()
	params.set_effect(entry.effect)
	params.value_changed.connect(func(prop_path, val, prev):
		effect_property_changed.emit(entry, prop_path, val, prev)
		# Only update the header label, don't rebuild the whole row / params panel.
		if _type_select and entry.effect is GFFEffectCommon:
			_type_select.text = _effect_display_name()
	)
	_params_container.add_child(params)

func _toggle_expand() -> void:
	is_expanded = not is_expanded
	_refresh()
	if is_expanded:
		_build_params()
	expand_toggled.emit(is_expanded)

func _effect_display_name() -> String:
	if entry == null or entry.effect == null:
		return "Unknown"
	
	var effect = entry.effect
	if effect is GFFEffectCommon:
		var target_name := ""
		var tweener_name := ""
		if effect.target:
			target_name = effect.target.get_target_name()
		if effect.tweener:
			tweener_name = effect.tweener.get_tweener_name()
		if target_name.is_empty() and tweener_name.is_empty():
			return "Effect Common"
		return "%s %s" % [target_name, tweener_name]
	
	var script_path = effect.get_script().get_path()
	var file = script_path.get_file().get_basename()
	return _capitalize(file.replace("gff_", ""))

func _capitalize(s: String) -> String:
	var parts = s.split("_")
	for i in range(parts.size()):
		parts[i] = parts[i].capitalize()
	return " ".join(parts)

func _update_style() -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.14, 0.15, 0.17)
	style.border_width_bottom = 1
	style.border_color = Color(0.09, 0.09, 0.1)
	style.content_margin_left = 4
	style.content_margin_right = 4
	style.content_margin_top = 2
	style.content_margin_bottom = 2
	add_theme_stylebox_override("panel", style)

func _get_icon(name: String) -> Texture2D:
	if Engine.is_editor_hint():
		return EditorInterface.get_editor_theme().get_icon(name, "EditorIcons")
	return null
