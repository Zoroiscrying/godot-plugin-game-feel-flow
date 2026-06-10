extends Node3D

## Game Feel Flow 3D Main Scene

# ===== Node References =====
@onready var camera: Camera3D = $Camera3D
@onready var objects: Node3D = $Objects
@onready var effect_list: ItemList = $UI/Panel/VBoxContainer/EffectList
@onready var param_panel: VBoxContainer = $UI/Panel/VBoxContainer/ScrollContainer/ParamPanel
@onready var play_button: Button = $UI/Panel/VBoxContainer/HBoxContainer/PlayButton
@onready var reset_button: Button = $UI/Panel/VBoxContainer/HBoxContainer/ResetButton
@onready var target_label: Label = $UI/Panel/VBoxContainer/TargetLabel

# ===== Properties =====
var _selected_target: MeshInstance3D = null
var _original_values: Dictionary = {}
var _moving_objects: Array[MeshInstance3D] = []
var _time: float = 0.0

# ===== Effect List =====
var effects: Array[Dictionary] = [
	{"name": "Shake", "type": "shake"},
	{"name": "Scale", "type": "scale"},
	{"name": "Flash", "type": "flash"},
	{"name": "Color", "type": "color"},
	{"name": "Hit Light", "type": "hit_light"},
	{"name": "Hit Medium", "type": "hit_medium"},
	{"name": "Hit Heavy", "type": "hit_heavy"},
	{"name": "Explosion", "type": "explosion"},
	{"name": "Death", "type": "death"},
]

# ===== Lifecycle =====

func _ready() -> void:
	print("=== Game Feel Flow 3D ===")
	print("Click objects to select target")

	# Enable debug mode
	GameFeelFlow.set_debug(true)

	_store_original()
	_find_moving_objects()
	_init_ui()

	effect_list.item_selected.connect(_on_effect_selected)
	play_button.pressed.connect(_on_play_pressed)
	reset_button.pressed.connect(_on_reset_pressed)

	# Select first object
	_select_target(objects.get_child(0))

func _process(delta: float) -> void:
	_time += delta
	_update_moving_objects(delta)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_click(event.position)

# ===== Initialization =====

func _store_original() -> void:
	for child in objects.get_children():
		if child is MeshInstance3D:
			_original_values[child] = {
				"position": child.position,
				"rotation": child.rotation,
				"scale": child.scale,
			}

func _find_moving_objects() -> void:
	var capsule = objects.get_node_or_null("MovingCapsule")
	if capsule:
		_moving_objects.append(capsule)

func _init_ui() -> void:
	for effect in effects:
		effect_list.add_item(effect["name"])

# ===== Moving Objects =====

func _update_moving_objects(delta: float) -> void:
	for obj in _moving_objects:
		if obj in _original_values:
			var original = _original_values[obj]
			var offset = Vector3(
				cos(_time) * 2.0,
				sin(_time * 0.5) * 0.5,
				sin(_time) * 2.0
			)
			obj.position = original["position"] + offset

# ===== Target Selection =====

func _handle_click(click_pos: Vector2) -> void:
	# Screen-space distance check (no collision shapes needed)
	var closest: MeshInstance3D = null
	var min_dist = 80.0  # Max pixel distance

	for child in objects.get_children():
		if child is MeshInstance3D:
			var screen_pos = camera.unproject_position(child.global_position)
			var dist = click_pos.distance_to(screen_pos)
			if dist < min_dist:
				min_dist = dist
				closest = child

	if closest:
		_select_target(closest)

func _select_target(target: MeshInstance3D) -> void:
	if _selected_target:
		_highlight(_selected_target, false)

	_selected_target = target

	if _selected_target:
		_highlight(_selected_target, true)
		target_label.text = "Target: " + _selected_target.name
	else:
		target_label.text = "Target: None"

func _highlight(obj: MeshInstance3D, on: bool) -> void:
	if not obj.material_override:
		return
	if on:
		obj.material_override.emission_enabled = true
		obj.material_override.emission = Color(0.5, 0.5, 0.5)
		obj.material_override.emission_energy_multiplier = 0.5
	else:
		obj.material_override.emission_enabled = false

# ===== Effect Selection =====

func _on_effect_selected(index: int) -> void:
	if index >= 0 and index < effects.size():
		var effect_type = effects[index]["type"]
		param_panel.show_params(effect_type)

# ===== Effect Playback =====

func _play_effect(effect_type: String) -> void:
	if not _selected_target:
		print("Please select a target first")
		return

	var params = param_panel.get_params()

	print("Playing: ", effect_type, " on ", _selected_target.name)

	match effect_type:
		"shake":
			GameFeelFlow.execute("shake", _selected_target, params)
		"scale":
			GameFeelFlow.execute("scale", _selected_target, params)
		"flash":
			GameFeelFlow.execute("flash", _selected_target, params)
		"color":
			GameFeelFlow.execute("color", _selected_target, params)
		"hit_light":
			GameFeelFlow.execute("hit", _selected_target, params)
		"hit_medium":
			GameFeelFlow.execute("hit", _selected_target, params)
		"hit_heavy":
			GameFeelFlow.execute("hit", _selected_target, params)
		"hit_critical":
			GameFeelFlow.execute("hit", _selected_target, params)
		"explosion":
			GameFeelFlow.execute("hit", _selected_target, params)
		"death":
			GameFeelFlow.execute("hit", _selected_target, params)

func _reset_all() -> void:
	for child in objects.get_children():
		if child in _original_values:
			var vals = _original_values[child]
			child.position = vals["position"]
			child.rotation = vals["rotation"]
			child.scale = vals["scale"]
			if child.material_override:
				child.material_override.emission_enabled = false

	camera.fov = 75.0
	Engine.time_scale = 1.0
	print("Reset")

# ===== Callbacks =====

func _on_play_pressed() -> void:
	var selected = effect_list.get_selected_items()
	if selected.size() > 0:
		_play_effect(effects[selected[0]]["type"])

func _on_reset_pressed() -> void:
	_reset_all()
