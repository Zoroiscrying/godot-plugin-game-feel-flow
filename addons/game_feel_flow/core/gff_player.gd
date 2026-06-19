class_name GFFPlayer
extends Node

## Game Feel Flow Player
##
## 播放器节点，类似Unity Feel的MMF_Player
## 支持Inspector配置、预设加载、效果播放

# ===== 信号 =====
signal effect_started(effect_name: String)
signal effect_finished(effect_name: String)
signal all_finished

# ===== 属性 =====
@export var auto_play: bool = false
@export var combo_presets: Array[GFFCombo] = []  # 预设组合
@export var preset_directory: String = "res://addons/game_feel_flow/presets/combos/"  # 预设目录

# ===== 运行时数据 =====
var _combo_dictionary: Dictionary = {}  # label -> GFFCombo
var _active_effects: Dictionary = {}
var _is_playing: bool = false

# ===== 生命周期 =====

func _ready() -> void:
	_load_presets()
	_build_combo_dictionary()
	
	if auto_play and not _combo_dictionary.is_empty():
		var first_key = _combo_dictionary.keys()[0]
		play(first_key)

# ===== 公共方法 =====

func play(combo_name: String, params = null) -> void:
	## 播放指定组合效果
	var combo = _combo_dictionary.get(combo_name)
	if combo:
		await _play_combo(combo, params)
	else:
		push_warning("GFFPlayer: Combo not found: ", combo_name)

func play_combo(combo: GFFCombo, params = null) -> void:
	## 播放组合效果
	if combo:
		await _play_combo(combo, params)

func play_all(params = null) -> void:
	## 播放所有组合效果
	_is_playing = true
	for combo_name in _combo_dictionary:
		play(combo_name, params)
		await get_tree().create_timer(0.5).timeout  # 间隔0.5秒
	_is_playing = false
	all_finished.emit()

func stop() -> void:
	## 停止所有效果
	for effect_id in _active_effects:
		var effect = _active_effects[effect_id]
		if effect and effect.has_method("stop"):
			effect.stop()
	_active_effects.clear()
	_is_playing = false

func is_playing() -> bool:
	## 是否正在播放
	return _is_playing

func get_combo_names() -> Array[String]:
	## 获取所有组合效果名称
	return _combo_dictionary.keys()

func has_combo(combo_name: String) -> bool:
	## 是否有指定组合效果
	return combo_name in _combo_dictionary

# ===== 内部方法 =====

func _play_combo(combo: GFFCombo, params = null) -> void:
	## 播放组合效果
	_is_playing = true
	effect_started.emit(combo.label)
	
	# 获取目标节点
	var target = _get_target_node()
	await combo.execute(target, _ensure_params(params))
	
	_is_playing = false
	effect_finished.emit(combo.label)

func _get_target_node() -> Node:
	## 获取目标节点
	# 查找子节点中的可操作节点
	for child in get_children():
		if child is Node2D or child is Node3D or child is Control:
			return child
	
	# 如果没有，返回父节点
	return get_parent() if get_parent() else self

func _ensure_params(params) -> GFFParams:
	## 确保参数是GFFParams类型
	if params == null:
		return GFFParams.create()
	elif params is float or params is int:
		return GFFParams.create(params)
	elif params is Dictionary:
		return GFFParams.from_dict(params)
	elif params is GFFParams:
		return params
	else:
		return GFFParams.create()

# ===== 预设管理 =====

func _load_presets() -> void:
	## 从目录加载预设
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
	## 构建组合效果字典
	_combo_dictionary.clear()
	
	# 从预设加载
	for combo in combo_presets:
		if combo and not combo.label.is_empty():
			_combo_dictionary[combo.label] = combo
	
	# 从代码预定义加载
	_combo_dictionary["hit_light"] = GFFCombo.hit_light()
	_combo_dictionary["hit_heavy"] = GFFCombo.hit_heavy()
	_combo_dictionary["death"] = GFFCombo.death()
	_combo_dictionary["pickup"] = GFFCombo.pickup()
	_combo_dictionary["explosion"] = GFFCombo.explosion()

func add_combo(combo: GFFCombo) -> void:
	## 添加组合效果
	if combo and not combo.label.is_empty():
		_combo_dictionary[combo.label] = combo
		combo_presets.append(combo)

func remove_combo(combo_name: String) -> void:
	## 移除组合效果
	_combo_dictionary.erase(combo_name)

func save_combo_as_preset(combo: GFFCombo, path: String) -> void:
	## 保存组合效果为预设文件
	var error = ResourceSaver.save(combo, path)
	if error == OK:
		print("GFFPlayer: Saved combo preset: ", path)
	else:
		push_error("GFFPlayer: Failed to save combo preset: ", path)
