class_name GFFPunchScale
extends GFFCurvedBase

## Game Feel Flow Punch Scale Effect
##
## 缩放冲击效果

# ===== 属性 =====
@export_group("Punch Settings")
@export var punch_scale: Vector2 = Vector2(1.3, 1.3)
@export var punch_scale_3d: Vector3 = Vector3(1.3, 1.3, 1.3)
@export var elasticity: float = 0.5

# ===== 重写方法 =====

func _init() -> void:
	tweener_type = TweenerType.ELASTIC
	super._init()

func _create_target_function() -> GFFTargetFunction:
	return GFFScaleTarget.new()

func _calculate_target_value(original_value: Variant, intensity: float) -> Variant:
	if original_value is Vector3:
		return punch_scale_3d * intensity
	elif original_value is Vector2:
		return Vector2(punch_scale.x * intensity, punch_scale.y * intensity)
	return original_value
