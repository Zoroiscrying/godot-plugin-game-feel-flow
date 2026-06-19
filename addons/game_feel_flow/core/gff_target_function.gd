class_name GFFTargetFunction
extends RefCounted

## Game Feel Flow Target Function
##
## 负责读写对象的属性，根据节点类型自动适配

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

# ===== 辅助方法 =====

func is_valid_node(node: Node) -> bool:
	## 检查节点是否有效
	return node != null and (node is Node2D or node is Node3D or node is Control)

func get_node_type(node: Node) -> int:
	## 获取节点类型
	if node is Node3D:
		return TYPE_NODE3D
	elif node is Node2D:
		return TYPE_NODE2D
	elif node is Control:
		return TYPE_CONTROL
	return TYPE_NIL
