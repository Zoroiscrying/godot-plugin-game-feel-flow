class_name GFFScaleTarget
extends GFFTargetFunction

## Game Feel Flow Scale Target
##
## 读写缩放属性，根据节点类型自动适配

func get_value(node: Node) -> Variant:
	if not is_valid_node(node):
		return Vector2.ONE
	
	if node is Node3D:
		return node.scale
	elif node is Node2D:
		return node.scale
	elif node is Control:
		return node.scale
	return Vector2.ONE

func set_value(node: Node, value: Variant) -> void:
	if not is_valid_node(node):
		return
	
	if node is Node3D:
		if value is Vector3:
			node.scale = value
		elif value is Vector2:
			node.scale = Vector3(value.x, value.y, 1)
	elif node is Node2D:
		if value is Vector2:
			node.scale = value
		elif value is Vector3:
			node.scale = Vector2(value.x, value.y)
	elif node is Control:
		if value is Vector2:
			node.scale = value

func get_default_value() -> Variant:
	return Vector2.ONE
