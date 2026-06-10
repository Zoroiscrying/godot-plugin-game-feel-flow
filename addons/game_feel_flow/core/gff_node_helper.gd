class_name GFFNodeHelper

## Game Feel Flow Node Helper
##
## Shared utility class for node property operations
## Supports Node2D, Node3D, and Control

# ===== Position =====

static func get_position(node: Node):
	## Get position from node
	if node is Node3D:
		return node.position
	elif node is Node2D:
		return node.position
	elif node is Control:
		return node.position
	return Vector2.ZERO

static func set_position(node: Node, pos) -> void:
	## Set position on node
	if node is Node3D:
		if pos is Vector3:
			node.position = pos
		elif pos is Vector2:
			node.position = Vector3(pos.x, pos.y, 0)
	elif node is Node2D:
		if pos is Vector2:
			node.position = pos
		elif pos is Vector3:
			node.position = Vector2(pos.x, pos.y)
	elif node is Control:
		if pos is Vector2:
			node.position = pos

# ===== Rotation =====

static func get_rotation(node: Node) -> float:
	## Get rotation from node (in radians)
	if node is Node3D:
		return node.rotation.y
	elif node is Node2D:
		return node.rotation
	elif node is Control:
		return node.rotation
	return 0.0

static func set_rotation(node: Node, r: float) -> void:
	## Set rotation on node (in radians)
	if node is Node3D:
		node.rotation.y = r
	elif node is Node2D:
		node.rotation = r
	elif node is Control:
		node.rotation = r

# ===== Scale =====

static func get_scale(node: Node):
	## Get scale from node
	if node is Node3D:
		return node.scale
	elif node is Node2D:
		return node.scale
	elif node is Control:
		return node.scale
	return Vector2.ONE

static func set_scale(node: Node, s) -> void:
	## Set scale on node
	if node is Node3D:
		if s is Vector3:
			node.scale = s
		elif s is Vector2:
			node.scale = Vector3(s.x, s.y, 1)
	elif node is Node2D:
		if s is Vector2:
			node.scale = s
		elif s is Vector3:
			node.scale = Vector2(s.x, s.y)
	elif node is Control:
		if s is Vector2:
			node.scale = s

# ===== Modulate =====

static func get_modulate(node: Node) -> Color:
	## Get modulate color (only for Node2D and Control)
	if node is Node2D:
		return node.modulate
	elif node is Control:
		return node.modulate
	return Color.WHITE

static func set_modulate(node: Node, c: Color) -> void:
	## Set modulate color (only for Node2D and Control)
	if node is Node2D:
		node.modulate = c
	elif node is Control:
		node.modulate = c

# ===== Target Resolution =====

static func get_target_node(target: Node) -> Node:
	## Get target node (supports Node2D, Node3D, Control)
	if target is Node2D or target is Node3D or target is Control:
		return target
	for child in target.get_children():
		if child is Node2D or child is Node3D or child is Control:
			return child
	return null

# ===== Camera =====

static func get_camera(target: Node):
	## Get camera from target (Camera2D or Camera3D)
	if target is Camera2D or target is Camera3D:
		return target
	for child in target.get_children():
		if child is Camera2D or child is Camera3D:
			return child
	return null

# ===== RigidBody =====

static func get_rigidbody(target: Node):
	## Get rigidbody from target (RigidBody2D or RigidBody3D)
	if target is RigidBody2D or target is RigidBody3D:
		return target
	for child in target.get_children():
		if child is RigidBody2D or child is RigidBody3D:
			return child
	return null

# ===== AnimationPlayer =====

static func get_animator(target: Node) -> AnimationPlayer:
	## Get AnimationPlayer from target
	if target is AnimationPlayer:
		return target
	for child in target.get_children():
		if child is AnimationPlayer:
			return child
	return null
