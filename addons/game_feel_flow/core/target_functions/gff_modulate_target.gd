class_name GFFModulateTarget
extends GFFTargetFunction

## Game Feel Flow Modulate Target
##
## 读写modulate属性，用于颜色和透明度效果

func get_value(node: Node) -> Variant:
	if not is_valid_node(node):
		return Color.WHITE
	
	if node is Node2D:
		return node.modulate
	elif node is Control:
		return node.modulate
	return Color.WHITE

func set_value(node: Node, value: Variant) -> void:
	if not is_valid_node(node):
		return
	
	if value is Color:
		if node is Node2D:
			node.modulate = value
		elif node is Control:
			node.modulate = value

func get_default_value() -> Variant:
	return Color.WHITE
