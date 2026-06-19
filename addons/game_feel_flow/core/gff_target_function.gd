class_name GFFTargetFunction
extends RefCounted

## Game Feel Flow Target Function
##
## 负责读写对象的属性

# ===== 虚方法 =====

func get_value(node: Node) -> Variant:
	## 获取属性值
	push_error("get_value() not implemented")
	return null

func set_value(node: Node, value: Variant) -> void:
	## 设置属性值
	push_error("set_value() not implemented")

func get_default_value() -> Variant:
	## 获取默认值
	push_error("get_default_value() not implemented")
	return null

func get_value_type() -> int:
	## 获取值类型
	push_error("get_value_type() not implemented")
	return 0
