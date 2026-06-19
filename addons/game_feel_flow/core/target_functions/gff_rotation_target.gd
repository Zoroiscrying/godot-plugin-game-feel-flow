class_name GFFRotationTarget
extends GFFTargetFunction

## Game Feel Flow Rotation Target
##
## 读写旋转属性，根据节点类型自动适配

func get_value(node: Node) -> Variant:
	if not is_valid_node(node):
		return 0.0
	
	if node is Node3D:
		return node.rotation.y
	elif node is Node2D:
		return node.rotation
	elif node is Control:
		return node.rotation
	return 0.0

func set_value(node: Node, value: Variant) -> void:
	if not is_valid_node(node):
		return
	
	if value is float:
		if node is Node3D:
			node.rotation.y = value
		elif node is Node2D:
			node.rotation = value
		elif node is Control:
			node.rotation = value

func get_default_value() -> Variant:
	return 0.0
