class_name GFFCurvedBase
extends GFFFeedback

## Game Feel Flow Curved Base Effect
##
## 曲线驱动效果基类，使用组合模式

# ===== 属性 =====
@export_group("Curved Settings")
@export var curve: Curve = null
@export var tweener_type: TweenerType = TweenerType.LINEAR

enum TweenerType {
	LINEAR,
	ELASTIC,
	SHAKE
}

# ===== 组合对象 =====
var _target_function: GFFTargetFunction = null
var _value_tweener: GFFValueTweener = null

# ===== 初始化 =====

func _init() -> void:
	_target_function = _create_target_function()
	_value_tweener = _create_tweener()

func _create_target_function() -> GFFTargetFunction:
	## 创建目标函数（子类重写）
	push_error("_create_target_function() not implemented")
	return null

func _create_tweener() -> GFFValueTweener:
	## 创建值变化器
	match tweener_type:
		TweenerType.LINEAR:
			return GFFLinearTweener.new()
		TweenerType.ELASTIC:
			return GFFElasticTweener.new()
		TweenerType.SHAKE:
			return GFFShakeTweener.new()
		_:
			return GFFLinearTweener.new()

# ===== 重写方法 =====

func _execute(node: Node, params: GFFParams) -> void:
	if not _target_function or not _value_tweener:
		push_error("GFFCurvedBase: Target function or value tweener not initialized")
		return
	
	if not _target_function.is_valid_node(node):
		push_warning("GFFCurvedBase: Invalid node type")
		return
	
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	
	var original_value = _target_function.get_value(node)
	var target_value = _calculate_target_value(original_value, intensity)
	
	await _value_tweener.tween_value(node, _target_function, original_value, target_value, final_duration, curve)

func _calculate_target_value(original_value: Variant, intensity: float) -> Variant:
	## 计算目标值（子类重写）
	push_error("_calculate_target_value() not implemented")
	return original_value

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
