@tool
class_name GFFParamPanel
extends VBoxContainer

## Game Feel Flow Parameter Panel (Timeline editor right panel)
## Reuses EffectParameterPanel so the timeline inspector exposes the same
## parameters as the main Inspector inspector.

signal param_changed(effect: GFFEffect, param_name: String, value: Variant)
signal clone_requested()
signal save_as_tres_requested()
signal preview_requested(effect: GFFEffect)

const EffectParameterPanelScene := preload("res://addons/game_feel_flow/editor/ui/effect_parameter_panel.tscn")

var _current_effect: GFFEffect = null
var _is_reference: bool = false
var _title_label: Label = null

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
	
	# Header: centered title on a dark background.
	var header = PanelContainer.new()
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var header_style = StyleBoxFlat.new()
	header_style.bg_color = Color(0.10, 0.12, 0.16)
	header_style.border_width_bottom = 2
	header_style.border_color = Color(0.06, 0.07, 0.09)
	header.add_theme_stylebox_override("panel", header_style)
	add_child(header)
	
	_title_label = Label.new()
	_title_label.text = display_name
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 16)
	_title_label.add_theme_color_override("font_color", Color(0.92, 0.94, 0.97))
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_title_label)
	
	if is_reference:
		var ref_label = Label.new()
		ref_label.text = "🔒 Reference (read-only)"
		ref_label.add_theme_color_override("font_color", Color(0.95, 0.88, 0.6))
		add_child(ref_label)
	
	# Parameters (reuse the same panel as the Inspector)
	_add_separator()
	var params = EffectParameterPanelScene.instantiate()
	params.set_effect(effect)
	if not is_reference:
		params.value_changed.connect(_on_param_value_changed)
	add_child(params)
	
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

func _clear_params() -> void:
	for child in get_children():
		child.queue_free()

func _add_separator() -> void:
	var sep = HSeparator.new()
	sep.custom_minimum_size.y = 8
	add_child(sep)

func _on_param_value_changed(property_path: String, value: Variant, _previous: Variant) -> void:
	if _current_effect == null:
		return
	_apply_effect_property(_current_effect, property_path, value)
	param_changed.emit(_current_effect, property_path, value)
	_update_title()

func _update_title() -> void:
	if _title_label == null or _current_effect == null:
		return
	_title_label.text = _get_effect_display_name(_current_effect)

func _get_effect_display_name(effect: GFFEffect) -> String:
	if effect == null:
		return "Effect"
	if not effect.resource_name.is_empty():
		return effect.resource_name
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

func _apply_effect_property(effect: GFFEffect, property_path: String, value: Variant) -> void:
	if effect == null:
		return
	var parts := property_path.split(":")
	var obj: Object = effect
	for i in range(parts.size() - 1):
		obj = obj.get(parts[i])
		if obj == null:
			return
	obj.set(parts[-1], value)
