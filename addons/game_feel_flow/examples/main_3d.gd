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
	{"name": "Hit Medium", "type": "hit_heavy"},
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
		_update_params(effect_type)

# ===== Effect Playback =====

func _play_effect(effect_type: String) -> void:
	if not _selected_target:
		print("Please select a target first")
		return

	var params = _get_params()
	print("Playing: ", effect_type, " on ", _selected_target.name, " with params: ", params)

	match effect_type:
		"shake":
			GFUtil.shake(_selected_target, params.get_float("intensity", 1.0))
		"scale":
			GFUtil.scale(_selected_target, params.get_float("intensity", 1.0))
		"flash":
			GFUtil.flash(_selected_target, params.get_color("color", Color.WHITE))
		"color":
			GFUtil.color(_selected_target, params.get_color("color", Color.RED))
		"hit_light":
			GFUtil.hit(_selected_target, params.get_float("intensity", 1.0))
		"hit_heavy":
			GFUtil.hit_heavy(_selected_target, params.get_float("intensity", 1.0))
		"explosion":
			GFUtil.explosion(_selected_target, params.get_float("intensity", 1.0))
		"death":
			GFUtil.death(_selected_target, params.get_float("intensity", 1.0))

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

# ===== Parameter Management =====

func _update_params(effect_type: String) -> void:
	# Clear existing params
	for child in param_panel.get_children():
		child.queue_free()
	
	# Add params based on effect type
	match effect_type:
		"shake":
			_add_float_param("intensity", 1.0, 0.0, 3.0)
			_add_float_param("duration", 0.15, 0.01, 0.5)
			_add_float_param("amplitude", 3.0, 0.5, 10.0)
			_add_float_param("frequency", 15.0, 5.0, 50.0)
		"scale":
			_add_float_param("intensity", 1.0, 0.0, 3.0)
			_add_float_param("duration", 0.15, 0.01, 0.5)
		"flash":
			_add_float_param("intensity", 1.0, 0.0, 3.0)
			_add_float_param("duration", 0.1, 0.01, 0.3)
			_add_color_param("color", Color.WHITE)
		"color":
			_add_float_param("intensity", 1.0, 0.0, 3.0)
			_add_float_param("duration", 0.15, 0.01, 0.3)
			_add_color_param("color", Color.RED)
		"hit_light", "hit_heavy", "explosion", "death":
			_add_float_param("intensity", 1.0, 0.0, 3.0)
		_:
			_add_float_param("intensity", 1.0, 0.0, 3.0)
			_add_float_param("duration", 0.15, 0.01, 0.5)

func _add_float_param(param_name: String, default: float, min_val: float, max_val: float) -> void:
	var hbox = HBoxContainer.new()
	
	var label = Label.new()
	label.text = param_name
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
	
	slider.value_changed.connect(func(value): value_label.text = "%.2f" % value)
	
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

# ===== Callbacks =====

func _on_play_pressed() -> void:
	var selected = effect_list.get_selected_items()
	if selected.size() > 0:
		_play_effect(effects[selected[0]]["type"])

func _on_reset_pressed() -> void:
	_reset_all()
