class_name GFFShakeScale
extends GFFCurvedBase

## Game Feel Flow Shake Scale Effect
##
## 缩放震动效果

# ===== 属性 =====
@export_group("Shake Settings")
@export var amplitude: float = 0.2
@export var axes: Vector3 = Vector3(1, 1, 0)

# ===== 重写方法 =====

func _init() -> void:
	tweener_type = TweenerType.SHAKE
	super._init()

func _create_target_function() -> GFFTargetFunction:
	return GFFScaleTarget.new()

func _calculate_target_value(original_value: Variant, intensity: float) -> Variant:
	# Shake不需要计算目标值，由tweener处理
	return original_value
