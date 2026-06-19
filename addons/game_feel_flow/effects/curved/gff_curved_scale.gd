class_name GFFCurvedScale
extends GFFCurvedBase

## Game Feel Flow Curved Scale Effect
##
## 曲线驱动的缩放变化

# ===== 属性 =====
@export_group("Scale Settings")
@export var target_scale: Vector2 = Vector2(1.2, 1.2)
@export var target_scale_3d: Vector3 = Vector3(1.2, 1.2, 1.2)

# ===== 重写方法 =====

func _create_target_function() -> GFFTargetFunction:
	return GFFScaleTarget.new()

func _calculate_target_value(original_value: Variant, intensity: float) -> Variant:
	if original_value is Vector3:
		return target_scale_3d * intensity
	elif original_value is Vector2:
		return Vector2(target_scale.x * intensity, target_scale.y * intensity)
	return original_value
