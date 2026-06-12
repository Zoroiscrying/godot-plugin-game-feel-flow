class_name GFFPlayer
extends Node

## Game Feel Flow Player
##
## 播放器节点，管理效果生命周期和编排

# ===== 信号 =====
signal effect_started(effect_name: String)
signal effect_finished(effect_name: String)
signal all_finished

# ===== 属性 =====
@export var auto_play: bool = false
@export var effects: Array[GFFFeedback] = []

# ===== 状态 =====
var _active_effects: Dictionary = {}
var _effect_queue: Array = []
var _is_playing: bool = false

# ===== 生命周期 =====

func _ready() -> void:
	if auto_play and not effects.is_empty():
		play_all()

# ===== 公共方法 =====

func play(effect, params = null) -> void:
	## 播放效果
	## effect: String | GFFFeedback | GFFCombo
	if effect is String:
		var feedback = _get_effect(effect)
		if feedback:
			await _play_feedback(feedback, params)
		else:
			push_warning("GFFPlayer: Effect not found: ", effect)
	elif effect is GFFFeedback:
		await _play_feedback(effect, params)
	elif effect is GFFCombo:
		await _play_combo(effect, params)

func play_combo(combo, params = null) -> void:
	## 播放组合效果
	## combo: String | GFFCombo
	if combo is String:
		var combo_resource = _get_combo(combo)
		if combo_resource:
			await _play_combo(combo_resource, params)
		else:
			push_warning("GFFPlayer: Combo not found: ", combo)
	elif combo is GFFCombo:
		await _play_combo(combo, params)

func play_all(params = null) -> void:
	## 播放所有效果
	_is_playing = true
	for effect in effects:
		if effect.enabled:
			_play_feedback(effect, params)

	# 等待所有效果完成
	while not _active_effects.is_empty():
		await get_tree().process_frame

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

func stop_effect(effect_name: String) -> void:
	## 停止指定效果
	if effect_name in _active_effects:
		var effect = _active_effects[effect_name]
		if effect and effect.has_method("stop"):
			effect.stop()
		_active_effects.erase(effect_name)

func is_playing() -> bool:
	## 是否正在播放
	return _is_playing

func is_effect_playing(effect_name: String) -> bool:
	## 指定效果是否正在播放
	return effect_name in _active_effects

# ===== 内部方法 =====

func _play_feedback(feedback: GFFFeedback, params = null) -> void:
	## 播放单个效果
	var effect_id = feedback.label if not feedback.label.is_empty() else str(feedback.get_instance_id())

	# 检查叠加策略
	match feedback.overlap_strategy:
		GFFFeedback.OverlapStrategy.IGNORE:
			if effect_id in _active_effects:
				return
		GFFFeedback.OverlapStrategy.CANCEL:
			if effect_id in _active_effects:
				stop_effect(effect_id)
		GFFFeedback.OverlapStrategy.REPLACE:
			if effect_id in _active_effects:
				stop_effect(effect_id)
		GFFFeedback.OverlapStrategy.QUEUE:
			if effect_id in _active_effects:
				_effect_queue.append({"effect": feedback, "params": params})
				return

	# 添加到活跃效果
	_active_effects[effect_id] = feedback
	effect_started.emit(effect_id)

	# 执行效果
	await feedback.apply(_get_target_node(), _ensure_params(params))

	# 从活跃效果中移除
	_active_effects.erase(effect_id)
	effect_finished.emit(effect_id)

	# 处理队列
	if not _effect_queue.is_empty():
		var next = _effect_queue.pop_front()
		_play_feedback(next["effect"], next["params"])

func _play_combo(combo: GFFCombo, params = null) -> void:
	## 播放组合效果
	if combo:
		var target = _get_target_node()
		await combo.execute(target, _ensure_params(params))

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

func _get_effect(effect_name: String) -> GFFFeedback:
	## 获取指定名称的效果
	for effect in effects:
		if effect.label == effect_name:
			return effect
	return null

func _get_combo(combo_name: String) -> GFFCombo:
	## 获取组合效果
	# 从全局单例获取
	var combo = GameFeelFlow.get_combo(combo_name)
	if combo:
		return combo
	
	return null

# ===== 编辑器方法 =====

func add_effect(effect: GFFFeedback) -> void:
	## 添加效果
	effects.append(effect)

func remove_effect(effect: GFFFeedback) -> void:
	## 移除效果
	effects.erase(effect)

func get_effects() -> Array[GFFFeedback]:
	## 获取所有效果
	return effects
