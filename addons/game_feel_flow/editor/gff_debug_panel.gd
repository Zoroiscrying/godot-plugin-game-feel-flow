@tool
extends Control

## Game Feel Flow Debug Panel
##
## 运行时调试面板，显示效果执行状态

# ===== 节点引用 =====
@onready var effect_list: ItemList = $VBoxContainer/EffectList
@onready var status_label: Label = $VBoxContainer/StatusLabel
@onready var fps_label: Label = $VBoxContainer/FPSLabel
@onready var memory_label: Label = $VBoxContainer/MemoryLabel
@onready var clear_button: Button = $VBoxContainer/ClearButton

# ===== 状态 =====
var _log_entries: Array[Dictionary] = []
var _active_effects: Dictionary = {}

# ===== 生命周期 =====

func _ready() -> void:
	_connect_signals()
	_update_status()
	_update_fps()
	_update_memory()

func _process(_delta: float) -> void:
	_update_fps()
	_update_memory()

func _connect_signals() -> void:
	if Engine.is_editor_hint():
		return
	if GameFeelFlow:
		GameFeelFlow.effect_started.connect(_on_effect_started)
		GameFeelFlow.effect_finished.connect(_on_effect_finished)
	if clear_button:
		clear_button.pressed.connect(_on_clear_pressed)

# ===== 回调方法 =====

func _on_effect_started(effect_name: String) -> void:
	_active_effects[effect_name] = Time.get_ticks_msec() / 1000.0
	_add_log_entry("STARTED", effect_name)
	_update_status()

func _on_effect_finished(effect_name: String) -> void:
	_active_effects.erase(effect_name)
	_add_log_entry("FINISHED", effect_name)
	_update_status()

func _on_clear_pressed() -> void:
	_log_entries.clear()
	_update_list()
	_update_status()

# ===== 内部方法 =====

func _add_log_entry(type: String, effect_name: String) -> void:
	var entry = {
		"time": Time.get_ticks_msec() / 1000.0,
		"type": type,
		"effect": effect_name,
	}
	_log_entries.append(entry)
	_update_list()

func _update_list() -> void:
	effect_list.clear()
	for entry in _log_entries:
		var text = "[%.2f] %s: %s" % [entry["time"], entry["type"], entry["effect"]]
		effect_list.add_item(text)

func _update_status() -> void:
	status_label.text = "Active Effects: %d | Log Entries: %d" % [_active_effects.size(), _log_entries.size()]

func _update_fps() -> void:
	if fps_label:
		fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

func _update_memory() -> void:
	if memory_label:
		var memory = OS.get_memory_info()
		memory_label.text = "Memory: %d MB" % (memory["physical"] / 1024 / 1024)
