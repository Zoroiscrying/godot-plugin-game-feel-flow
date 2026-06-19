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

# ===== 默认参数（用于预设） =====
var _default_amplitude: float = 0.5
var _default_frequency: float = 15.0
var _default_elasticity: float = 0.5
var _default_flash_color: Color = Color.WHITE
var _default_target_x: float = 0.0
var _default_target_y: float = 0.0
var _default_target_z: float = 0.0

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
	
	# 合并默认参数和传入参数
	var merged_params = _merge_params(params)
	
	# 让tweener从params中读取参数
	_value_tweener.setup_from_params(merged_params)
	
	var intensity = merged_params.get_float("intensity", 1.0)
	var final_duration = merged_params.get_float("duration", duration)
	
	var original_value = _target_function.get_value(node)
	var target_value = _calculate_target_value(original_value, merged_params)
	
	await _value_tweener.tween_value(node, _target_function, original_value, target_value, final_duration, curve)

func _merge_params(params: GFFParams) -> GFFParams:
	## 合并默认参数和传入参数
	var merged = GFFParams.create()
	
	# 设置默认值
	merged.with_float("amplitude", _default_amplitude)
	merged.with_float("frequency", _default_frequency)
	merged.with_float("elasticity", _default_elasticity)
	merged.with_color("color", _default_flash_color)
	merged.with_float("target_x", _default_target_x)
	merged.with_float("target_y", _default_target_y)
	merged.with_float("target_z", _default_target_z)
	
	# 用传入参数覆盖
	if params:
		merged.intensity = params.intensity
		merged.duration = params.duration
		for key in params._data:
			merged._data[key] = params._data[key]
	
	return merged

func _calculate_target_value(original_value: Variant, params: GFFParams) -> Variant:
	var intensity = params.get_float("intensity", 1.0)
	var target_x = params.get_float("target_x", 0.0)
	var target_y = params.get_float("target_y", 0.0)
	var target_z = params.get_float("target_z", 0.0)
	
	match target_type:
		TargetType.POSITION:
			if original_value is Vector3:
				return original_value + Vector3(target_x, target_y, target_z) * intensity
			elif original_value is Vector2:
				return original_value + Vector2(target_x, target_y) * intensity
		TargetType.SCALE:
			if original_value is Vector3:
				return original_value + Vector3(target_x, target_y, target_z) * intensity
			elif original_value is Vector2:
				return original_value + Vector2(target_x, target_y) * intensity
		TargetType.ROTATION:
			if original_value is float:
				return original_value + deg_to_rad(target_x * intensity)
	return original_value

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
