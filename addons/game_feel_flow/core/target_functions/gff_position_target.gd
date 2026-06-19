class_name GFFPositionTarget
extends GFFTargetFunction

## Game Feel Flow Position Target
##
## 读写位置属性

func get_value(node: Node) -> Variant:
	if node is Node3D:
		return node.position
	elif node is Node2D:
		return node.position
	elif node is Control:
		return node.position
	return Vector2.ZERO

func set_value(node: Node, value: Variant) -> void:
	if node is Node3D:
		if value is Vector3:
			node.position = value
		elif value is Vector2:
			node.position = Vector3(value.x, value.y, 0)
	elif node is Node2D:
		if value is Vector2:
			node.position = value
		elif value is Vector3:
			node.position = Vector2(value.x, value.y)
	elif node is Control:
		if value is Vector2:
			node.position = value

func get_default_value() -> Variant:
	return Vector2.ZERO

func get_value_type() -> int:
	return TYPE_VECTOR2
