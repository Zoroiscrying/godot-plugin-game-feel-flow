extends Control

## Performance monitor sub-scene
## Display FPS, effect execution time, memory usage and other performance data

# ===== Node References =====
@onready var fps_chart: Control = $VBoxContainer/TabContainer/FPS/Chart
@onready var fps_label: Label = $VBoxContainer/TabContainer/FPS/FPSLabel
@onready var effects_list: ItemList = $VBoxContainer/TabContainer/Effects/List
@onready var memory_label: Label = $VBoxContainer/TabContainer/Memory/Label
@onready var active_label: Label = $VBoxContainer/TabContainer/Active/Label

# ===== Properties =====
var fps_history: Array[float] = []
var max_history: int = 100

# ===== Lifecycle =====

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	_update_fps()
	_update_memory()
	_update_active_effects()

# ===== Performance Update =====

func _update_fps() -> void:
	var fps = Engine.get_frames_per_second()
	fps_history.append(fps)
	if fps_history.size() > max_history:
		fps_history.pop_front()
	
	if fps_label:
		fps_label.text = "FPS: %d" % fps
	
	_update_fps_chart()

func _update_fps_chart() -> void:
	if not fps_chart or fps_history.is_empty():
		return
	
	# Update chart data
	fps_chart.update_data(fps_history, max_history)

func _update_memory() -> void:
	if memory_label:
		var memory = OS.get_memory_info()
		memory_label.text = "Memory: %d MB" % (memory["physical"] / 1024 / 1024)

func _update_active_effects() -> void:
	if active_label:
		# Count active effects
		active_label.text = "Active Effects: 0"
