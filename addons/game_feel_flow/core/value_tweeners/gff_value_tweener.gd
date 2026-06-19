class_name GFFValueTweener
extends RefCounted

## Game Feel Flow Value Tweener
##
## 针对对应的参数以及类型，选择合适的方式改变参数

# ===== 虚方法 =====

func tween_value(node: Node, target_function: GFFTargetFunction, from: Variant, to: Variant, duration: float, curve: Curve = null) -> void:
	## 变化值
	push_error("tween_value() not implemented")

func get_value_at_time(t: float, from: Variant, to: Variant, curve: Curve = null) -> Variant:
	## 获取指定时间的值
	push_error("get_value_at_time() not implemented")
	return null

func setup_from_params(params: GFFParams) -> void:
	## 从GFFParams中读取参数（子类重写）
	pass
