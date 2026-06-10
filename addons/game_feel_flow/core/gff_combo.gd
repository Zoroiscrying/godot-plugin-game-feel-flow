class_name GFFCombo
extends Resource

## Game Feel Flow Combo
##
## 组合效果，按顺序执行多个反馈效果

# ===== 属性 =====
@export var effects: Array[GFFFeedback] = []
@export var params: GFFParams = null

# ===== 信号 =====
signal started
signal finished

# ===== 状态 =====
var _is_playing: bool = false

# ===== 公共方法 =====

func play(target: Node = null, override_params = null) -> void:
	## 播放组合效果
	if effects.is_empty():
		return

	_is_playing = true
	started.emit()

	for effect in effects:
		if not effect.enabled:
			continue
		if target:
			await effect.apply(target, _merge_params(override_params))

	_is_playing = false
	finished.emit()

func execute(target: Node, params = null) -> void:
	## 执行组合效果（GFFPlayer调用）
	await play(target, params)

func stop() -> void:
	## 停止组合效果
	_is_playing = false

func is_playing() -> bool:
	## 是否正在播放
	return _is_playing

# ===== 内部方法 =====

func _merge_params(override_params) -> GFFParams:
	## 合并参数
	var base = params if params else GFFParams.new()

	if override_params is GFFParams:
		return override_params
	elif override_params is float:
		var merged = GFFParams.new()
		merged.intensity = override_params
		merged.duration = base.duration
		return merged
	elif override_params is Dictionary:
		var merged = GFFParams.new()
		merged.intensity = override_params.get("intensity", base.intensity)
		merged.duration = override_params.get("duration", base.duration)
		return merged

	return base

# ===== 静态工厂方法 =====

static func hit_light() -> GFFCombo:
	var combo = GFFCombo.new()
	return combo

static func hit_heavy() -> GFFCombo:
	var combo = GFFCombo.new()
	return combo

static func death() -> GFFCombo:
	var combo = GFFCombo.new()
	return combo

static func pickup() -> GFFCombo:
	var combo = GFFCombo.new()
	return combo

static func explosion() -> GFFCombo:
	var combo = GFFCombo.new()
	return combo
