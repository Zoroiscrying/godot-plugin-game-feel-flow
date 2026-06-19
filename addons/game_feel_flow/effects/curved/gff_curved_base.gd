class_name GFFCurvedBase
extends GFFFeedback

## Game Feel Flow Curved Base Effect
##
## 曲线驱动效果基类，通过配置TargetFunction和ValueTweener实现所有效果

# ===== 属性 =====
@export_group("Curved Settings")
@export var target_type: TargetType = TargetType.POSITION
@export var tweener_type: TweenerType = TweenerType.LINEAR
@export var curve: Curve = null

@export_group("Target Settings")
@export var target_value: Vector2 = Vector2.ZERO
@export var target_value_3d: Vector3 = Vector3.ZERO
@export var target_angle: float = 0.0

@export_group("Shake Settings")
@export var amplitude: float = 0.5
@export var frequency: float = 15.0
@export var axes: Vector3 = Vector3(1, 1, 0)

@export_group("Punch Settings")
@export var elasticity: float = 0.5

enum TargetType {
	POSITION,
	SCALE,
	ROTATION
}

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
	match target_type:
		TargetType.POSITION:
			return GFFPositionTarget.new()
		TargetType.SCALE:
			return GFFScaleTarget.new()
		TargetType.ROTATION:
			return GFFRotationTarget.new()
		_:
			return GFFPositionTarget.new()

func _create_tweener() -> GFFValueTweener:
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
	match target_type:
		TargetType.POSITION:
			if original_value is Vector3:
				return original_value + target_value_3d * intensity
			elif original_value is Vector2:
				return original_value + Vector2(target_value.x * intensity, target_value.y * intensity)
		TargetType.SCALE:
			if original_value is Vector3:
				return target_value_3d * intensity
			elif original_value is Vector2:
				return Vector2(target_value.x * intensity, target_value.y * intensity)
		TargetType.ROTATION:
			if original_value is float:
				return original_value + deg_to_rad(target_angle * intensity)
	return original_value

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
