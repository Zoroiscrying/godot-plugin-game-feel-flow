@tool
extends VBoxContainer

## GFFPlayer Inspector main panel (Unity Feel style)

signal open_timeline_requested
signal property_changed

const ComboRowScene := preload("res://addons/game_feel_flow/editor/ui/combo_row.tscn")
const EffectRowScene := preload("res://addons/game_feel_flow/editor/ui/effect_row.tscn")
const DragContainerScript := preload("res://addons/game_feel_flow/editor/ui/drag_container.gd")

const _NON_COPYABLE_PROPS := ["script", "Script", "resource_path", "resource_name", "resource_local_to_scene"]

const MIN_PANEL_HEIGHT := 300.0

var _player: GFFPlayer = null
var _undo_redo: EditorUndoRedoManager = null

var _combo_list: VBoxContainer
var _effect_list: VBoxContainer
var _combo_header: Label
var _effect_title: Label
var _auto_play_btn: CheckButton
var _selected_combo_key: String = ""
var _expanded_entry_index: int = -1

## Inspector foldout/selection state is stored on the inspected GFFPlayer via
## metadata. Godot rebuilds the entire CombosPanel whenever the inspected object
## changes, so instance variables are not enough to keep foldouts open.
const META_SELECTED_COMBO := &"_gff_inspector_selected_combo"
const META_EXPANDED_ENTRY := &"_gff_inspector_expanded_entry"

func set_player(player: GFFPlayer) -> void:
	_player = player
	_undo_redo = EditorInterface.get_editor_undo_redo()
	_restore_state()
	_refresh()

func _restore_state() -> void:
	if _player == null:
		_selected_combo_key = ""
		_expanded_entry_index = -1
		return
	if _player.has_meta(META_SELECTED_COMBO):
		_selected_combo_key = _player.get_meta(META_SELECTED_COMBO)
		_expanded_entry_index = _player.get_meta(META_EXPANDED_ENTRY)
	else:
		_selected_combo_key = _player.active_combo_key
		_expanded_entry_index = -1
		_save_state()

func _save_state() -> void:
	if _player == null:
		return
	_player.set_meta(META_SELECTED_COMBO, _selected_combo_key)
	_player.set_meta(META_EXPANDED_ENTRY, _expanded_entry_index)

func _ready() -> void:
	_build_ui()
	_refresh()

func _build_ui() -> void:
	add_theme_constant_override("separation", 8)
	custom_minimum_size = Vector2(0, MIN_PANEL_HEIGHT)

	# Toolbar
	var toolbar = HBoxContainer.new()
	toolbar.add_theme_constant_override("separation", 6)
	add_child(toolbar)

	var play_btn = Button.new()
	play_btn.text = "Play"
	play_btn.icon = _get_icon("Play")
	play_btn.tooltip_text = "Play active combo"
	play_btn.pressed.connect(_on_play_pressed)
	toolbar.add_child(play_btn)

	_auto_play_btn = CheckButton.new()
	_auto_play_btn.text = "Auto Play"
	_auto_play_btn.tooltip_text = "Play the default combo or effects array on scene start"
	_auto_play_btn.toggled.connect(_on_auto_play_toggled)
	toolbar.add_child(_auto_play_btn)

	var add_combo_btn = Button.new()
	add_combo_btn.text = "Combo"
	add_combo_btn.icon = _get_icon("Add")
	add_combo_btn.pressed.connect(_on_add_combo)
	toolbar.add_child(add_combo_btn)

	var load_preset_btn = MenuButton.new()
	load_preset_btn.text = "Load Built-in"
	load_preset_btn.icon = _get_icon("Load")
	_build_builtin_menu(load_preset_btn)
	toolbar.add_child(load_preset_btn)

	var timeline_btn = Button.new()
	timeline_btn.text = "Timeline Editor"
	timeline_btn.icon = _get_icon("AnimationTrackGroup")
	timeline_btn.pressed.connect(func(): open_timeline_requested.emit())
	# Timeline Editor is a Pro-only dock; hide the button when Pro is not present.
	timeline_btn.visible = FileAccess.file_exists("res://addons/game_feel_flow_pro/plugin.cfg")
	toolbar.add_child(timeline_btn)

	add_child(HSeparator.new())

	# Combo list
	_combo_header = Label.new()
	_combo_header.text = "Combos"
	_combo_header.add_theme_color_override("font_color", Color(0.75, 0.78, 0.85))
	add_child(_combo_header)

	_combo_list = VBoxContainer.new()
	_combo_list.set_script(DragContainerScript)
	_combo_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_combo_list.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_combo_list.connect("child_moved", _on_combo_moved)
	add_child(_combo_list)

	add_child(HSeparator.new())

	# Effect section header (title + add controls on same line)
	var effect_header = HBoxContainer.new()
	effect_header.add_theme_constant_override("separation", 6)
	add_child(effect_header)

	_effect_title = Label.new()
	_effect_title.text = "Effects"
	_effect_title.add_theme_color_override("font_color", Color(0.75, 0.78, 0.85))
	_effect_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_effect_title.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	effect_header.add_child(_effect_title)

	var effect_select = OptionButton.new()
	effect_select.custom_minimum_size = Vector2(100, 0)
	_populate_effect_types(effect_select)
	effect_header.add_child(effect_select)

	var add_effect_btn = Button.new()
	add_effect_btn.text = "+ Effect"
	add_effect_btn.icon = _get_icon("Add")
	add_effect_btn.pressed.connect(func():
		_on_add_effect(effect_select.get_item_metadata(effect_select.selected))
	)
	effect_header.add_child(add_effect_btn)

	# Effect list expands naturally with content; the outer inspector scrolls.
	_effect_list = VBoxContainer.new()
	_effect_list.set_script(DragContainerScript)
	_effect_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_effect_list.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_effect_list.connect("child_moved", _on_effect_moved)
	add_child(_effect_list)

func _refresh() -> void:
	if _auto_play_btn and _player:
		_auto_play_btn.set_block_signals(true)
		_auto_play_btn.button_pressed = _player.auto_play
		_auto_play_btn.set_block_signals(false)
	_refresh_combo_list()
	_refresh_effect_list()
	_save_state()

func _refresh_combo_list() -> void:
	if not _combo_list:
		return
	for child in _combo_list.get_children():
		child.queue_free()

	if _player == null:
		return

	var keys = _player.combo_dictionary.keys()
	if _combo_header:
		_combo_header.text = "Combos (%d)" % keys.size()
	if keys.is_empty():
		var empty = Label.new()
		empty.text = "No combos. Click + Combo to add one."
		empty.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
		_combo_list.add_child(empty)
		return

	for i in range(keys.size()):
		var key = keys[i]
		var row = ComboRowScene.instantiate()
		row.combo = _player.combo_dictionary.get(key)
		row.combo_key = key
		row.is_selected = (key == _selected_combo_key)
		row.is_default = (_player.default_combo_index == i)
		row.selected.connect(_on_combo_selected.bind(key))
		row.key_renamed.connect(_on_combo_renamed)
		row.deleted.connect(_on_combo_deleted.bind(key))
		row.duplicated.connect(_on_combo_duplicated.bind(key))
		row.save_as_project_requested.connect(_on_combo_save_as_project.bind(key))
		row.set_default_requested.connect(_on_combo_set_default.bind(i))
		_combo_list.add_child(row)

func _refresh_effect_list() -> void:
	if not _effect_list:
		return
	_expanded_entry_index = -1
	for child in _effect_list.get_children():
		if "is_expanded" in child and child.is_expanded:
			_expanded_entry_index = child.entry_index
			break
	_save_state()
	for child in _effect_list.get_children():
		child.queue_free()

	if _player == null or _selected_combo_key.is_empty():
		var empty = Label.new()
		empty.text = "Select a combo to edit effects."
		empty.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
		_effect_list.add_child(empty)
		return

	var combo = _player.combo_dictionary.get(_selected_combo_key)
	if combo == null:
		return

	var effect_count := 0
	for entry in combo.entries:
		if entry and entry.effect:
			effect_count += 1
	if _effect_title:
		_effect_title.text = "Effects (%d)" % effect_count

	if combo.entries.is_empty():
		var empty = Label.new()
		empty.text = "No effects. Select a type and click + Effect."
		empty.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
		_effect_list.add_child(empty)
		return

	for i in range(combo.entries.size()):
		var entry = combo.entries[i]
		if entry == null or entry.effect == null:
			continue
		var row = EffectRowScene.instantiate()
		row.entry_index = i
		row.is_expanded = (i == _expanded_entry_index)
		row.entry = entry
		row.category_color = _category_color(entry.effect)
		row.toggled.connect(func(v):
			_player.editor_set_entry_enabled(_selected_combo_key, i, v)
		)
		row.deleted.connect(_on_effect_deleted.bind(i))
		row.entry_changed.connect(_mark_changed)
		row.effect_type_changed.connect(_on_effect_type_changed)
		row.copy_requested.connect(_on_effect_copy)
		row.paste_requested.connect(_on_effect_paste.bind(i))
		row.effect_property_changed.connect(_on_effect_property_changed)
		row.entry_property_changed.connect(_on_entry_property_changed)
		row.expand_toggled.connect(_on_effect_expand_toggled.bind(i))
		_effect_list.add_child(row)

func _on_combo_moved(last_index: int, new_index: int) -> void:
	if last_index == new_index:
		return
	var keys = _player.combo_dictionary.keys()
	if last_index < 0 or last_index >= keys.size():
		return
	var key = keys[last_index]
	var old_dict = _snapshot_dict()
	var new_keys = keys.duplicate()
	new_keys.remove_at(last_index)
	new_keys.insert(clampi(new_index, 0, new_keys.size()), key)
	_player.combo_dictionary.clear()
	for k in new_keys:
		_player.combo_dictionary[k] = old_dict[k]
	_commit_dict_action("Reorder Combo", old_dict)
	_mark_changed()

func _on_effect_moved(last_index: int, new_index: int) -> void:
	if last_index == new_index:
		return
	var combo = _player.combo_dictionary.get(_selected_combo_key)
	if combo == null or last_index < 0 or last_index >= combo.entries.size():
		return
	var old_dict = _snapshot_dict()
	var entry = combo.entries[last_index]
	combo.entries.remove_at(last_index)
	combo.entries.insert(clampi(new_index, 0, combo.entries.size()), entry)
	_commit_dict_action("Reorder Effect", old_dict)
	_mark_changed()

func _on_combo_selected(key: String) -> void:
	_selected_combo_key = key
	if _player:
		_player.active_combo_key = key
	_expanded_entry_index = -1
	_save_state()
	_refresh()

func _on_combo_renamed(old_key: String, new_key: String) -> void:
	var old_dict = _snapshot_dict()
	if _player.editor_rename_combo(old_key, new_key):
		if _selected_combo_key == old_key:
			_selected_combo_key = new_key
		_commit_dict_action("Rename Combo", old_dict)
		_mark_changed()

func _on_combo_deleted(key: String) -> void:
	var old_dict = _snapshot_dict()
	var deleted_index := _player.combo_dictionary.keys().find(key)
	_player.editor_delete_combo(key)
	if _selected_combo_key == key:
		_selected_combo_key = ""
	if deleted_index == _player.default_combo_index:
		_player.default_combo_index = -1
	elif deleted_index >= 0 and deleted_index < _player.default_combo_index:
		_player.default_combo_index -= 1
	_commit_dict_action("Delete Combo", old_dict)
	_mark_changed()

func _on_combo_set_default(index: int) -> void:
	if _player.default_combo_index == index:
		_player.default_combo_index = -1
	else:
		_player.default_combo_index = index
	_mark_changed()
	_refresh()

func _on_combo_duplicated(key: String) -> void:
	var combo = _player.combo_dictionary.get(key)
	if combo == null:
		return
	var old_dict = _snapshot_dict()
	var new_key = _player.editor_add_combo(key + "_copy")
	_player.combo_dictionary[new_key] = combo.duplicate()
	_selected_combo_key = new_key
	_commit_dict_action("Duplicate Combo", old_dict)
	_mark_changed()

func _on_combo_save_as_project(key: String) -> void:
	var combo: GFFCombo = _player.combo_dictionary.get(key)
	if combo == null:
		return
	var path := GFFProjectSettings.save_combo(combo, key, true)
	if path.is_empty():
		return
	print("Game Feel Flow: Saved project combo to ", path)
	_register_saved_project_combo(combo, path)
	GFFEditorFS.reveal_path(path)

func _register_saved_project_combo(combo: GFFCombo, path: String) -> void:
	## When Pro is present, register into GameFeelFlow so play_combo works immediately.
	if not FileAccess.file_exists("res://addons/game_feel_flow_pro/core/gff_project_combos.gd"):
		return
	var ProjectCombos = load("res://addons/game_feel_flow_pro/core/gff_project_combos.gd")
	if ProjectCombos == null:
		return
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return
	var runtime_gff = tree.root.get_node_or_null("/root/GameFeelFlow")
	if runtime_gff:
		ProjectCombos.register_combo_resource(runtime_gff, combo, path.get_file())
	var free_plugin_script = load("res://addons/game_feel_flow/plugin.gd")
	if free_plugin_script and free_plugin_script.editor_game_feel_flow:
		var editor_gff = free_plugin_script.editor_game_feel_flow
		if editor_gff and editor_gff != runtime_gff:
			ProjectCombos.register_combo_resource(editor_gff, combo, path.get_file())

func _on_add_combo() -> void:
	var old_dict = _snapshot_dict()
	var key = _player.editor_add_combo(_player.name if _player.name else "Combo")
	_selected_combo_key = key
	_commit_dict_action("Add Combo", old_dict)
	_mark_changed()

func _on_effect_deleted(index: int) -> void:
	var old_dict = _snapshot_dict()
	_player.editor_remove_effect_from_combo(_selected_combo_key, index)
	_commit_dict_action("Delete Effect", old_dict)
	_mark_changed()

func _on_effect_expand_toggled(index: int, is_expanded: bool) -> void:
	if is_expanded:
		_expanded_entry_index = index
	elif _expanded_entry_index == index:
		_expanded_entry_index = -1
	_save_state()

func _on_effect_type_changed(entry: GFFComboEntry, new_path: String) -> void:
	if entry == null or entry.effect == null:
		return
	var script := load(new_path) as Script
	if script == null:
		return
	var new_effect := script.new() as GFFEffect
	if new_effect == null:
		return

	var old_dict := _snapshot_dict()
	_copy_effect_properties(entry.effect, new_effect)
	entry.effect = new_effect
	_commit_dict_action("Change Effect Type", old_dict)
	_mark_changed()

func _copy_effect_properties(from: GFFEffect, to: GFFEffect) -> void:
	if from == null or to == null:
		return
	for prop in from.get_property_list():
		if prop.name in _NON_COPYABLE_PROPS:
			continue
		if not (prop.usage & PROPERTY_USAGE_STORAGE):
			continue
		if prop.name in to:
			to.set(prop.name, from.get(prop.name))

func _on_effect_copy(entry: GFFComboEntry) -> void:
	if entry == null or entry.effect == null:
		return
	GFFEffectClipboard.copy(entry.effect)
	_refresh_effect_list()
	_mark_changed()

func _on_effect_paste(entry: GFFComboEntry, index: int) -> void:
	if entry == null or entry.effect == null:
		return
	if not GFFEffectClipboard.can_paste(entry.effect):
		return

	var old_effect := entry.effect.duplicate()
	GFFEffectClipboard.paste(entry.effect)
	var pasted_effect := entry.effect

	_undo_redo.create_action("Paste Effect Parameters")
	_undo_redo.add_do_method(self, "_apply_effect_replace", entry, pasted_effect)
	_undo_redo.add_undo_method(self, "_apply_effect_replace", entry, old_effect)
	_undo_redo.add_do_method(self, "_refresh")
	_undo_redo.add_undo_method(self, "_refresh")
	_undo_redo.commit_action()
	_mark_changed()

func _apply_effect_replace(entry: GFFComboEntry, effect: GFFEffect) -> void:
	if entry == null:
		return
	entry.effect = effect

func _on_effect_property_changed(entry: GFFComboEntry, property_path: String, value: Variant, previous: Variant) -> void:
	_undo_redo.create_action("Set %s" % property_path)
	_undo_redo.add_do_method(self, "_apply_effect_property", entry, property_path, value)
	_undo_redo.add_undo_method(self, "_apply_effect_property", entry, property_path, previous)
	_undo_redo.add_do_method(self, "_refresh")
	_undo_redo.add_undo_method(self, "_refresh")
	_undo_redo.commit_action()
	_mark_changed()

func _apply_effect_property(entry: GFFComboEntry, property_path: String, value: Variant) -> void:
	if entry == null or entry.effect == null:
		return
	var parts := property_path.split(":")
	var obj: Object = entry.effect
	for i in range(parts.size() - 1):
		obj = obj.get(parts[i])
		if obj == null:
			return
	obj.set(parts[-1], value)

func _on_entry_property_changed(entry: GFFComboEntry, property: String, value: Variant, previous: Variant) -> void:
	_undo_redo.create_action("Set %s" % property)
	_undo_redo.add_do_property(entry, property, value)
	_undo_redo.add_undo_property(entry, property, previous)
	_undo_redo.add_do_method(self, "_refresh")
	_undo_redo.add_undo_method(self, "_refresh")
	_undo_redo.commit_action()
	_mark_changed()

func _on_add_effect(preset_name: String) -> void:
	var effect := GFFEffectRegistry.create_preset(preset_name)
	if effect:
		var old_dict = _snapshot_dict()
		if _player.editor_add_effect_to_combo(_selected_combo_key, effect):
			_commit_dict_action("Add Effect", old_dict)
			_mark_changed()

func _on_play_pressed() -> void:
	if _player and not _selected_combo_key.is_empty():
		_player.stop()
		_player.play(_selected_combo_key)

func _on_auto_play_toggled(enabled: bool) -> void:
	if _player == null:
		return
	_undo_redo.create_action("Toggle Auto Play")
	_undo_redo.add_do_property(_player, "auto_play", enabled)
	_undo_redo.add_undo_property(_player, "auto_play", _player.auto_play)
	_undo_redo.add_do_method(self, "_refresh")
	_undo_redo.add_undo_method(self, "_refresh")
	_undo_redo.commit_action()
	_mark_changed()

const BUILTIN_COMBO_FACTORIES := {
	"hit_light": "hit_light",
	"hit_medium": "hit_medium",
	"hit_heavy": "hit_heavy",
	"hit_critical": "hit_critical",
	"death": "death",
	"death_explosion": "death_explosion",
	"pickup": "pickup",
	"pickup_coin": "pickup_coin",
	"pickup_health": "pickup_health",
	"pickup_power": "pickup_power",
	"explosion": "explosion",
	"explosion_small": "explosion_small",
	"explosion_large": "explosion_large",
	"ui_button_press": "ui_button_press",
	"ui_notification": "ui_notification",
}

func _build_builtin_menu(btn: MenuButton) -> void:
	var popup = btn.get_popup()
	var names := BUILTIN_COMBO_FACTORIES.keys()
	for i in range(names.size()):
		popup.add_item(names[i], i)
		popup.set_item_metadata(i, names[i])
	popup.id_pressed.connect(func(id: int):
		var name = popup.get_item_metadata(id)
		var factory = BUILTIN_COMBO_FACTORIES[name]
		var combo = GFFCombo.new().call(factory)
		var old_dict = _snapshot_dict()
		var key = _player.editor_add_combo(name)
		_player.combo_dictionary[key] = combo.duplicate()
		_selected_combo_key = key
		_commit_dict_action("Load Built-in Combo", old_dict)
		_mark_changed()
	)

func _snapshot_dict() -> Dictionary:
	return _player.combo_dictionary.duplicate()

func _apply_dict_snapshot(snapshot: Dictionary) -> void:
	_player.combo_dictionary.clear()
	for key in snapshot.keys():
		_player.combo_dictionary[key] = snapshot[key]
	_refresh()

func _commit_dict_action(action_name: String, old_dict: Dictionary) -> void:
	var new_dict = _snapshot_dict()
	_undo_redo.create_action(action_name)
	_undo_redo.add_do_method(self, "_apply_dict_snapshot", new_dict)
	_undo_redo.add_undo_method(self, "_apply_dict_snapshot", old_dict)
	_undo_redo.add_do_method(self, "_refresh")
	_undo_redo.add_undo_method(self, "_refresh")
	_undo_redo.commit_action()

func _populate_effect_types(select: OptionButton) -> void:
	for preset_name in GFFEffectRegistry.get_preset_names():
		select.add_item(preset_name)
		var idx := select.item_count - 1
		select.set_item_metadata(idx, preset_name)

func _category_color(effect: GFFEffect) -> Color:
	if effect is GFFEffectCommon:
		if effect.target:
			match effect.target.get_target_name():
				"Position", "Scale", "Rotation":
					return Color(0.25, 0.65, 0.95)
				"Color", "Alpha":
					return Color(0.95, 0.45, 0.25)
		return Color(0.6, 0.6, 0.65)

	var path = effect.get_script().get_path()
	if "/visual/" in path: return Color(0.95, 0.45, 0.25)
	if "/transform/" in path: return Color(0.25, 0.65, 0.95)
	if "/camera/" in path: return Color(0.85, 0.35, 0.95)
	if "/audio/" in path: return Color(0.35, 0.85, 0.55)
	if "/time/" in path: return Color(0.95, 0.75, 0.25)
	if "/particles/" in path: return Color(0.35, 0.75, 0.85)
	if "/ui/" in path: return Color(0.55, 0.55, 0.95)
	if "/events/" in path: return Color(0.95, 0.55, 0.35)
	return Color(0.6, 0.6, 0.65)

func _mark_changed() -> void:
	EditorInterface.mark_scene_as_unsaved()
	property_changed.emit()

func _get_icon(name: String) -> Texture2D:
	if Engine.is_editor_hint():
		return EditorInterface.get_editor_theme().get_icon(name, "EditorIcons")
	return null
