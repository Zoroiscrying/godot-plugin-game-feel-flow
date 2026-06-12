class_name GFFFeedback
extends Resource

## Game Feel Flow Feedback Base
##
## 所有效果的基类，继承Resource支持Inspector配置和.tres文件

# ===== 叠加策略 =====
enum OverlapStrategy {
	ADD,      # 叠加 - 多个效果同时生效
	REPLACE,  # 替换 - 新效果替换旧效果
	QUEUE,    # 排队 - 等待前一个完成
	IGNORE,   # 忽略 - 如果正在播放则跳过
	CANCEL    # 取消 - 停止当前，播放新的
}

# ===== 基础属性 =====
@export var enabled: bool = true
@export var label: String = ""
@export var priority: int = 0
@export var overlap_strategy: OverlapStrategy = OverlapStrategy.REPLACE

# ===== 时间控制 =====
@export_group("Timing")
@export var duration: float = 0.1
@export var delay: float = 0.0
@export var cooldown: float = 0.0

# ===== 恢复控制 =====
@export_group("Restore")
@export var restore_after_play: bool = false

# ===== 随机性 =====
@export_group("Randomness")
@export var random_duration_min: float = 1.0
@export var random_duration_max: float = 1.0
@export var random_intensity_min: float = 1.0
@export var random_intensity_max: float = 1.0

# ===== 曲线 =====
@export_group("Curve")
@export var easing_curve: Curve = null

# ===== 信号 =====
signal started
signal finished

# ===== 状态 =====
var _is_playing: bool = false
var _initial_state: Dictionary = {}
var _last_play_time: float = 0.0

# ===== 公共方法 =====

func apply(target: Node, params: GFFParams = null) -> void:
	## 执行效果
	if not enabled:
		return

	# Reentrancy guard
	if _is_playing:
		match overlap_strategy:
			OverlapStrategy.IGNORE:
				return
			OverlapStrategy.CANCEL:
				stop()
			_:
				pass

	# 检查冷却时间
	if cooldown > 0.0 and Time.get_ticks_msec() / 1000.0 - _last_play_time < cooldown:
		return

	# 延迟执行
	if delay > 0.0:
		await target.get_tree().create_timer(delay).timeout

	# 解析目标节点
	var node = _resolve_target(target)
	if not node:
		push_warning("GFFFeedback: No valid target node found")
		return

	# 保存初始状态
	if restore_after_play:
		_save_initial_state(node)

	# 计算随机参数
	var final_duration = duration * randf_range(random_duration_min, random_duration_max)
	var final_intensity = _get_intensity(params) * randf_range(random_intensity_min, random_intensity_max)

	# 创建最终参数
	var final_params = _create_final_params(params, final_intensity, final_duration)

	# 执行效果
	_is_playing = true
	started.emit()
	_last_play_time = Time.get_ticks_msec() / 1000.0

	await _execute(node, final_params)

	# 恢复初始状态
	if restore_after_play:
		_restore_initial_state(node)

	_is_playing = false
	finished.emit()

func stop() -> void:
	## 停止效果
	_is_playing = false

func is_playing() -> bool:
	## 是否正在播放
	return _is_playing

# ===== 虚方法（子类必须实现） =====

func _execute(node: Node, params: GFFParams) -> void:
	## 执行效果逻辑（子类实现）
	push_error("_execute() not implemented in ", get_class())

func _get_default_intensity() -> float:
	## 获取默认强度（子类可重写）
	return 1.0

func _get_default_duration() -> float:
	## 获取默认持续时间（子类可重写）
	return duration

# ===== 辅助方法 =====

func _resolve_target(target: Node) -> Node:
	## 解析目标节点
	if not target:
		return null
	
	if target is Node2D or target is Node3D or target is Control:
		return target

	# 查找子节点中的可操作节点
	for child in target.get_children():
		if child is Node2D or child is Node3D or child is Control:
			return child

	return null

func _save_initial_state(node: Node) -> void:
	## 保存初始状态
	_initial_state = {
		"position": _get_position(node),
		"rotation": _get_rotation(node),
		"scale": _get_scale(node),
		"modulate": _get_modulate(node),
	}

func _restore_initial_state(node: Node) -> void:
	## 恢复初始状态
	if _initial_state.is_empty():
		return

	_set_position(node, _initial_state["position"])
	_set_rotation(node, _initial_state["rotation"])
	_set_scale(node, _initial_state["scale"])
	_set_modulate(node, _initial_state["modulate"])

func _get_intensity(params: GFFParams) -> float:
	## 获取强度参数
	if params:
		return params.get_float("intensity", _get_default_intensity())
	return _get_default_intensity()

func _get_duration_param(params: GFFParams) -> float:
	## 获取持续时间参数
	if params:
		return params.get_float("duration", _get_default_duration())
	return _get_default_duration()

func _create_final_params(params: GFFParams, intensity: float, duration: float) -> GFFParams:
	## 创建最终参数
	var final_params = GFFParams.new()
	final_params.intensity = intensity
	final_params.duration = duration

	if params:
		# 复制额外参数（跳过已计算的 intensity 和 duration）
		for key in params._data:
			if key != "intensity" and key != "duration":
				final_params._data[key] = params._data[key]

	return final_params

func _apply_curve(value: float, curve: Curve) -> float:
	## 应用曲线
	if curve:
		return curve.sample(value)
	return value

# ===== 节点操作方法 =====

func _get_position(node: Node):
	if node is Node3D:
		return node.position
	elif node is Node2D:
		return node.position
	elif node is Control:
		return node.position
	return Vector2.ZERO

func _set_position(node: Node, pos) -> void:
	if node is Node3D:
		if pos is Vector3:
			node.position = pos
		elif pos is Vector2:
			node.position = Vector3(pos.x, pos.y, 0)
	elif node is Node2D:
		if pos is Vector2:
			node.position = pos
		elif pos is Vector3:
			node.position = Vector2(pos.x, pos.y)
	elif node is Control:
		if pos is Vector2:
			node.position = pos

func _get_rotation(node: Node) -> float:
	if node is Node3D:
		return node.rotation.y
	elif node is Node2D:
		return node.rotation
	elif node is Control:
		return node.rotation
	return 0.0

func _set_rotation(node: Node, r: float) -> void:
	if node is Node3D:
		node.rotation.y = r
	elif node is Node2D:
		node.rotation = r
	elif node is Control:
		node.rotation = r

func _get_scale(node: Node):
	if node is Node3D:
		return node.scale
	elif node is Node2D:
		return node.scale
	elif node is Control:
		return node.scale
	return Vector2.ONE

func _set_scale(node: Node, s) -> void:
	if node is Node3D:
		if s is Vector3:
			node.scale = s
		elif s is Vector2:
			node.scale = Vector3(s.x, s.y, 1)
	elif node is Node2D:
		if s is Vector2:
			node.scale = s
		elif s is Vector3:
			node.scale = Vector2(s.x, s.y)
	elif node is Control:
		if s is Vector2:
			node.scale = s

func _get_modulate(node: Node) -> Color:
	if node is Node2D:
		return node.modulate
	elif node is Control:
		return node.modulate
	return Color.WHITE

func _set_modulate(node: Node, c: Color) -> void:
	if node is Node2D:
		node.modulate = c
	elif node is Control:
		node.modulate = c
