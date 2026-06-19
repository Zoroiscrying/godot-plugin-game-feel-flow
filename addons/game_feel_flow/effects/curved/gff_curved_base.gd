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

enum TargetType {
	POSITION,
	SCALE,
	ROTATION,
	MODULATE
}

enum TweenerType {
	LINEAR,
	ELASTIC,
	SHAKE,
	FLASH,
	COLOR
}

# ===== 组合对象 =====
var _target_function: GFFTargetFunction = null
var _value_tweener: GFFValueTweener = null
var _initialized: bool = false

# ===== 初始化 =====

func _ensure_initialized() -> void:
	if not _initialized:
		_target_function = _create_target_function()
		_value_tweener = _create_tweener()
		_initialized = true

func _create_target_function() -> GFFTargetFunction:
	match target_type:
		TargetType.POSITION:
			return GFFPositionTarget.new()
		TargetType.SCALE:
			return GFFScaleTarget.new()
		TargetType.ROTATION:
			return GFFRotationTarget.new()
		TargetType.MODULATE:
			return GFFModulateTarget.new()
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
		TweenerType.FLASH:
			return GFFFlashTweener.new()
		TweenerType.COLOR:
			return GFFColorTweener.new()
		_:
			return GFFLinearTweener.new()

# ===== 重写方法 =====

func _execute(node: Node, params: GFFParams) -> void:
	_ensure_initialized()
	
	if not _target_function or not _value_tweener:
		push_error("GFFCurvedBase: Target function or value tweener not initialized")
		return
	
	if not _target_function.is_valid_node(node):
		push_warning("GFFCurvedBase: Invalid node type")
		return
	
	# 让tweener从params中读取参数
	_value_tweener.setup_from_params(params)
	
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	
	var original_value = _target_function.get_value(node)
	var target_value = _calculate_target_value(original_value, intensity)
	
	await _value_tweener.tween_value(node, _target_function, original_value, target_value, final_duration, curve)

func _calculate_target_value(original_value: Variant, intensity: float) -> Variant:
	# 从params中获取target值
	var params = GFFParams.create(intensity)
	var target_offset = _get_target_offset(params)
	
	match target_type:
		TargetType.POSITION:
			if original_value is Vector3:
				return original_value + target_offset
			elif original_value is Vector2:
				return original_value + Vector2(target_offset.x, target_offset.y)
		TargetType.SCALE:
			if original_value is Vector3:
				return original_value + target_offset
			elif original_value is Vector2:
				return original_value + Vector2(target_offset.x, target_offset.y)
		TargetType.ROTATION:
			if original_value is float:
				return original_value + deg_to_rad(target_offset.x)
	return original_value

func _get_target_offset(params: GFFParams) -> Vector3:
	## 从params中获取目标偏移量
	var x = params.get_float("target_x", 0.0)
	var y = params.get_float("target_y", 0.0)
	var z = params.get_float("target_z", 0.0)
	return Vector3(x, y, z)

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
