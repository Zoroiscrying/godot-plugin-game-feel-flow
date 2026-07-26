@tool
class_name GFFPlayer
extends Node

## Game Feel Flow Player
##
## Player node, similar to Unity Feel's MMF_Player
## Supports Inspector config, preset loading, and effect playback

const GFFEffectStackScript = preload("res://addons/game_feel_flow/core/gff_effect_stack.gd")

# ===== Signals =====
signal effect_started(effect_name: String)
signal effect_finished(effect_name: String)
signal all_finished

# ===== Properties =====
@export var auto_play: bool = false
## Index of the combo to play automatically when auto_play is enabled. Defaults to the first combo (0).
@export var default_combo_index: int = 0
@export var combo_presets: Array[GFFCombo] = []  # Optional: load preset combos from project .tres
@export var preset_directory: String = "res://addons/game_feel_flow/presets/combos/"  # Preset directory

# ===== Timeline Editor Data =====
## GFFPlayer's local Combo dictionary (string key -> GFFCombo).
## Timeline Editor edits Combos in this dictionary by default.
@export var combo_dictionary: Dictionary[String, GFFCombo] = {}
@export var active_combo_key: String = ""       # The combo key currently being edited in Timeline Editor
@export var default_params: GFFParams = null    # This player's default params

# ===== Backwards Compatibility (Migration Only)=====
@export var active_combo: GFFCombo = null       # Deprecated: old Timeline save location
@export var timeline_data: Array[Dictionary] = []  # Deprecated: old lightweight timeline data

# ===== Runtime Data =====
var _combo_dictionary: Dictionary = {}  # label -> GFFCombo (includes built-in + local + presets)
var _feedback_stack = null  # Running feedback stack
var _active_combo: GFFCombo = null      # Currently playing combo
var _is_playing: bool = false

# ===== Effect list (supports Inspector and code)=====
@export var effects: Array[GFFEffect] = []

# ===== Lifecycle =====

func _ready() -> void:
	_ensure_stack()

	_load_presets()
	_build_combo_dictionary()
	_build_effect_dictionary()

	# Don't auto-play in editor to avoid triggering effects during scene editing
	if Engine.is_editor_hint():
		return

	if not auto_play:
		return

	# Clamp default combo index and play the configured default combo if valid.
	var combo_count := combo_dictionary.size()
	default_combo_index = clampi(default_combo_index, -1, max(combo_count - 1, -1))
	if default_combo_index >= 0 and default_combo_index < combo_count:
		var key = combo_dictionary.keys()[default_combo_index]
		play(key)
		return

	# If effects are configured directly on this player, play them as a combo.
	if effects.size() > 0:
		play()
		return

	# No default combo and no effects: do nothing instead of silently playing a built-in combo.

# ===== Public Methods =====

func _ensure_stack() -> void:
	if _feedback_stack != null:
		return
	_feedback_stack = GFFEffectStackScript.new()
	_feedback_stack.effect_started.connect(_on_stack_effect_started)
	_feedback_stack.effect_finished.connect(_on_stack_effect_finished)
	_feedback_stack.all_finished.connect(_on_stack_all_finished)

func play(effect = null, params = null) -> void:
	## Play effect
	## effect: String | GFFEffect | GFFCombo | null(plays effects array when null)
	_ensure_stack()
	if effect == null:
		# Build a temporary combo from effects array and play it
		_play_effects_as_combo(params)
		return

	if effect is String:
		# First look up the effect list
		var feedback = _get_effect(effect)
		if feedback:
			await _play_feedback(feedback.duplicate(true), params)
			return

		# Then look up combo (local dictionary, built-in, presets, then global/project)
		var combo = _combo_dictionary.get(effect)
		if combo == null:
			var gff = _game_feel_flow_autoload()
			if gff and gff.has_method("resolve_combo"):
				combo = gff.resolve_combo(effect)
		if combo:
			await _play_combo(combo.duplicate(true), params)
		else:
			push_warning("GFFPlayer: Effect or combo not found: ", effect)
	elif effect is GFFEffect:
		await _play_feedback(effect, params)
	elif effect is GFFCombo:
		await _play_combo(effect, params)

func play_combo(combo, params = null) -> void:
	## Play combo effect
	## combo: String | GFFCombo
	if combo is String:
		var combo_resource = _combo_dictionary.get(combo)
		if combo_resource == null:
			var gff = _game_feel_flow_autoload()
			if gff and gff.has_method("resolve_combo"):
				combo_resource = gff.resolve_combo(combo)
		if combo_resource:
			await _play_combo(combo_resource.duplicate(true), params)
		else:
			push_warning("GFFPlayer: Combo not found: ", combo)
	elif combo is GFFCombo:
		await _play_combo(combo, params)

func play_all(params = null) -> void:
	## Play all effects
	_is_playing = true
	for effect in effects:
		if effect.enabled:
			await _play_feedback(effect.duplicate(true), params)
	_is_playing = false
	all_finished.emit()

func _play_effects_as_combo(params = null) -> void:
	## Build a temporary combo from effects array, scheduled using unified GFFCombo.execute()
	if effects.is_empty():
		push_warning("GFFPlayer: No effects to play")
		return

	var combo = GFFCombo.new()
	combo.label = "Inspector_Play"
	var current_time = 0.0
	for i in range(effects.size()):
		var effect = effects[i]
		if effect and effect.enabled:
			var entry = GFFComboEntry.new()
			entry.effect = effect
			if effect.delay > 0:
				entry.start_time = effect.delay
			else:
				entry.start_time = current_time
				current_time += effect.duration
			entry.duration = effect.duration
			entry.track_idx = 0
			entry.enabled = true
			combo.entries.append(entry)

	if combo.entries.is_empty():
		push_warning("GFFPlayer: No active effects to play")
		return

	await _play_combo(combo, _ensure_params(params))
	all_finished.emit()

func stop() -> void:
	## Stop all effects
	if _feedback_stack:
		_feedback_stack.stop()

	if _active_combo and _active_combo.has_method("stop"):
		_active_combo.stop()
	_active_combo = null

	_is_playing = false

func stop_effect(effect_name: String) -> void:
	## Stop specified effect
	if _feedback_stack:
		_feedback_stack.stop_effect(effect_name)

func is_playing() -> bool:
	## Is playing
	if _feedback_stack:
		return _feedback_stack.is_playing() or _is_playing
	return _is_playing

func is_effect_playing(effect_name: String) -> bool:
	## Whether specified effect is playing
	if _feedback_stack:
		return _feedback_stack.is_effect_playing(effect_name)
	return false

func get_combo_names() -> Array[String]:
	## Get all combo names
	return _combo_dictionary.keys()

func has_combo(combo_name: String) -> bool:
	## Whether specified combo exists
	return combo_name in _combo_dictionary

# ===== Effect Management =====

func add_effect(effect: GFFEffect) -> void:
	## Add effect
	if effect not in effects:
		effects.append(effect)
		_build_effect_dictionary()

func remove_effect(effect: GFFEffect) -> void:
	## Remove effect
	effects.erase(effect)
	_build_effect_dictionary()

func get_effects() -> Array[GFFEffect]:
	## Get all effects
	return effects.duplicate()

# ===== Preset Management =====

func add_combo(combo: GFFCombo, key: String = "") -> void:
	## Add combo to local dictionary
	## If key is not specified, defaults to combo.label
	if not combo:
		return
	var final_key = key if not key.is_empty() else combo.label
	if final_key.is_empty():
		push_warning("GFFPlayer: Cannot add combo without key or label")
		return
	combo_dictionary[final_key] = combo
	_build_combo_dictionary()

func remove_combo(key: String) -> void:
	## Remove combo from local dictionary
	combo_dictionary.erase(key)
	if active_combo_key == key:
		active_combo_key = ""
	_build_combo_dictionary()

func register_combo_from_file(path: String, key: String = "") -> String:
	## Load .tres files from project and register them in local dictionary
	## Returns the actually used key
	if path.is_empty():
		push_warning("GFFPlayer: Empty combo file path")
		return ""
	var combo = load(path)
	if not combo is GFFCombo:
		push_warning("GFFPlayer: Not a valid GFFCombo resource: ", path)
		return ""
	var final_key = key if not key.is_empty() else combo.label
	if final_key.is_empty():
		final_key = path.get_file().get_basename()
	combo_dictionary[final_key] = combo
	_build_combo_dictionary()
	return final_key

func save_combo_as_preset(combo: GFFCombo, path: String) -> void:
	## Save combo as preset file (export .tres)
	var error = ResourceSaver.save(combo, path)
	if error == OK:
		print("GFFPlayer: Saved combo preset: ", path)
	else:
		push_error("GFFPlayer: Failed to save combo preset: ", path)

# ===== Inspector / Editor Helpers =====
## The following methods are called by Editor Inspector to modify combo_dictionary,
## separated from runtime playback logic.

func editor_add_combo(key_hint: String = "") -> String:
	## Add an empty combo to combo_dictionary, return the actual key
	var base = key_hint if not key_hint.is_empty() else (name if name else "Combo")
	var key = _generate_unique_key(base)
	var combo = GFFCombo.new()
	combo.label = key
	combo_dictionary[key] = combo
	active_combo_key = key
	_build_combo_dictionary()
	return key

func editor_rename_combo(old_key: String, new_key: String) -> bool:
	## Rename combo key
	new_key = new_key.strip_edges()
	if old_key.is_empty() or new_key.is_empty() or new_key == old_key:
		return false
	if not combo_dictionary.has(old_key):
		return false
	if combo_dictionary.has(new_key):
		push_warning("GFFPlayer: Combo key already exists: " + new_key)
		return false
	var combo = combo_dictionary[old_key]
	combo_dictionary.erase(old_key)
	combo_dictionary[new_key] = combo
	if active_combo_key == old_key:
		active_combo_key = new_key
	_build_combo_dictionary()
	return true

func editor_delete_combo(key: String) -> void:
	## Delete combo
	combo_dictionary.erase(key)
	if active_combo_key == key:
		active_combo_key = ""
	_build_combo_dictionary()

func editor_add_effect_to_combo(key: String, effect: GFFEffect) -> bool:
	## Add an effect to the specified combo; defaults to a new track so it plays alongside other effects.
	## For sequential waves, users can set track_idx to the same track and adjust start_time in Inspector/Timeline.
	if key.is_empty() or not combo_dictionary.has(key) or not effect:
		return false
	var combo = combo_dictionary[key]
	var duration = effect.duration if effect.duration > 0 else 0.3
	var track_idx: int = combo.entries.size()
	combo.add_entry(effect, 0.0, duration, track_idx)
	return true

func editor_remove_effect_from_combo(key: String, entry_index: int) -> bool:
	## Remove specified entry from combo
	if key.is_empty() or not combo_dictionary.has(key):
		return false
	var combo = combo_dictionary[key]
	if entry_index < 0 or entry_index >= combo.entries.size():
		return false
	combo.entries.remove_at(entry_index)
	return true

func editor_set_entry_enabled(key: String, entry_index: int, value: bool) -> bool:
	## Set enabled state of combo entry
	if key.is_empty() or not combo_dictionary.has(key):
		return false
	var combo = combo_dictionary[key]
	if entry_index < 0 or entry_index >= combo.entries.size():
		return false
	combo.entries[entry_index].enabled = value
	return true

func _generate_unique_key(base: String) -> String:
	if not combo_dictionary.has(base):
		return base
	var index = 1
	while combo_dictionary.has(base + "_" + str(index)):
		index += 1
	return base + "_" + str(index)

# ===== Internal Methods =====

func _play_feedback(feedback: GFFEffect, params = null) -> void:
	## Play single effect
	_ensure_stack()

	var target = _get_target_node()
	var final_params = _ensure_params(params)
	var started = _feedback_stack.play(feedback, target, final_params)
	if started:
		await feedback.finished

func _play_combo(combo: GFFCombo, params = null) -> void:
	## Play combo effect
	_is_playing = true
	_active_combo = combo
	effect_started.emit(combo.label)

	# Get target node
	var target = _get_target_node()
	await combo.execute(target, _ensure_params(params))

	if _active_combo == combo:
		_active_combo = null
	_is_playing = false
	effect_finished.emit(combo.label)

func _get_target_node() -> Node:
	## Get target node
	# Find child node
	for child in get_children():
		if child is Node2D or child is Node3D or child is Control:
			return child

	# If neither, return parent node
	return get_parent() if get_parent() else self

func _ensure_params(params) -> GFFParams:
	## Ensure params is a GFFParams type
	var result: GFFParams = null

	if params == null:
		result = GFFParams.create()
	elif params is float or params is int:
		result = GFFParams.create(params)
	elif params is Dictionary:
		result = GFFParams.from_dict(params)
	elif params is GFFParams:
		# Copy once to avoid modifying the object passed by caller
		result = GFFParams.new()
		result.intensity = params.intensity
		result.duration = params.duration
		for key in params._data:
			result._data[key] = params._data[key]
	else:
		result = GFFParams.create()

	# Merge with player's default_params (passed params take priority)
	if default_params != null:
		if result.intensity == 1.0 and default_params.intensity != 1.0:
			result.intensity = default_params.intensity
		if result.duration < 0 and default_params.duration >= 0:
			result.duration = default_params.duration
		for key in default_params._data:
			if not result._data.has(key):
				result._data[key] = default_params._data[key]

	return result

func _load_presets() -> void:
	## Load presets from directory
	var dir = DirAccess.open(preset_directory)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var path = preset_directory + file_name
				var combo = load(path)
				if combo is GFFCombo:
					combo_presets.append(combo)
			file_name = dir.get_next()

func _build_combo_dictionary() -> void:
	## Build combo dictionary
	## Priority: local combo_dictionary > combo_presets > code predefined
	_combo_dictionary.clear()

	# 1. Code predefined (built-in Combos)
	_register_builtin_combos()

	# 2. .tres presets loaded from preset_directory
	for combo in combo_presets:
		if combo:
			var key = combo.label if not combo.label.is_empty() else str(combo.get_instance_id())
			_combo_dictionary[key] = combo

	# 3. GFFPlayer local dictionary (Timeline Editor default edit location)
	for key in combo_dictionary.keys():
		var combo = combo_dictionary[key]
		if combo:
			_combo_dictionary[key] = combo

	# 4. Migrate old active_combo / timeline_data
	_migrate_legacy_combo_data()

func _register_builtin_combos() -> void:
	## Register code-predefined built-in Combos
	_combo_dictionary["hit_light"] = GFFCombo.hit_light()
	_combo_dictionary["hit_medium"] = GFFCombo.hit_medium()
	_combo_dictionary["hit_heavy"] = GFFCombo.hit_heavy()
	_combo_dictionary["hit_critical"] = GFFCombo.hit_critical()
	_combo_dictionary["death"] = GFFCombo.death()
	_combo_dictionary["death_explosion"] = GFFCombo.death_explosion()
	_combo_dictionary["pickup"] = GFFCombo.pickup()
	_combo_dictionary["pickup_coin"] = GFFCombo.pickup_coin()
	_combo_dictionary["pickup_health"] = GFFCombo.pickup_health()
	_combo_dictionary["pickup_power"] = GFFCombo.pickup_power()
	_combo_dictionary["explosion"] = GFFCombo.explosion()
	_combo_dictionary["explosion_small"] = GFFCombo.explosion_small()
	_combo_dictionary["explosion_large"] = GFFCombo.explosion_large()
	_combo_dictionary["ui_button_press"] = GFFCombo.ui_button_press()
	_combo_dictionary["ui_notification"] = GFFCombo.ui_notification()

func _migrate_legacy_combo_data() -> void:
	## Migrate old active_combo / timeline_data to combo_dictionary
	if active_combo != null:
		var key = active_combo.label if not active_combo.label.is_empty() else "active"
		if not combo_dictionary.has(key):
			combo_dictionary[key] = active_combo
		if active_combo_key.is_empty():
			active_combo_key = key
		# Clear old references after migration to avoid duplicate imports
		active_combo = null

	if timeline_data.size() > 0 and combo_dictionary.is_empty():
		var migrated = GFFCombo.new()
		migrated.label = name + "_combo"
		for entry in timeline_data:
			if entry is Dictionary:
				var effect = entry.get("effect") as GFFEffect
				var track_idx = entry.get("track_idx", 0)
				var start_time = entry.get("start_time", 0.0)
				var duration = entry.get("duration", 0.3)
				if effect:
					migrated.add_entry(effect, start_time, duration, track_idx)
		if migrated.entries.size() > 0:
			combo_dictionary[migrated.label] = migrated
			active_combo_key = migrated.label
		timeline_data.clear()

func _build_effect_dictionary() -> void:
	## Build effect dictionary (lookup by label)
	pass

func _get_effect(effect_name: String) -> GFFEffect:
	## Look up from effect list
	for effect in effects:
		if effect.label == effect_name:
			return effect
	return null

func _game_feel_flow_autoload() -> Node:
	## Resolve the GameFeelFlow autoload without requiring Engine singleton APIs.
	var tree := get_tree()
	if tree and tree.root:
		return tree.root.get_node_or_null("GameFeelFlow")
	return null

func _on_stack_effect_started(effect_id: String) -> void:
	effect_started.emit(effect_id)

func _on_stack_effect_finished(effect_id: String) -> void:
	effect_finished.emit(effect_id)

func _on_stack_all_finished() -> void:
	if not _is_playing:
		all_finished.emit()
