extends Control

## 性能监控子场景
## 显示FPS、效果执行时间、内存使用等性能数据

# ===== 节点引用 =====
@onready var fps_chart: Control = $VBoxContainer/TabContainer/FPS/Chart
@onready var fps_label: Label = $VBoxContainer/TabContainer/FPS/FPSLabel
@onready var effects_list: ItemList = $VBoxContainer/TabContainer/Effects/List
@onready var memory_label: Label = $VBoxContainer/TabContainer/Memory/Label
@onready var active_label: Label = $VBoxContainer/TabContainer/Active/Label

# ===== 属性 =====
var fps_history: Array[float] = []
var max_history: int = 100

# ===== 生命周期 =====

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	_update_fps()
	_update_memory()
	_update_active_effects()

# ===== 性能更新 =====

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
	
	# 更新图表数据
	fps_chart.update_data(fps_history, max_history)

func _update_memory() -> void:
	if memory_label:
		var memory = OS.get_memory_info()
		memory_label.text = "Memory: %d MB" % (memory["physical"] / 1024 / 1024)

func _update_active_effects() -> void:
	if active_label:
		# 统计活跃效果数
		active_label.text = "Active Effects: 0"
