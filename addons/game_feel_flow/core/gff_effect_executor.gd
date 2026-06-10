class_name GFFEffectExecutor
extends Node

## Game Feel Flow Effect Executor
##
## Executes GFFEffect configurations

# ===== State =====
var _active_effects: Dictionary = {}
var _effect_counter: int = 0

# ===== Public Methods =====

func execute_effect(effect, target: Node) -> void:
	## Execute any effect
	if effect.has_method("execute"):
		await effect.execute(target, self)
	elif effect.has_method("apply"):
		await effect.apply(target)

# ===== Helper Methods =====

func _get_target_node(target: Node) -> Node:
	## Get target node (supports Node2D, Node3D, Control)
	if target is Node2D or target is Node3D or target is Control:
		return target
	for child in target.get_children():
		if child is Node2D or child is Node3D or child is Control:
			return child
	return null

func _get_position(node: Node):
	## Get position from node
	if node is Node3D:
		return node.position
	elif node is Node2D:
		return node.position
	elif node is Control:
		return node.position
	return Vector2.ZERO

func _set_position(node: Node, pos) -> void:
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

func _get_rotation(node: Node) -> float:
	## Get rotation from node
	if node is Node3D:
		return node.rotation.y
	elif node is Node2D:
		return node.rotation
	elif node is Control:
		return node.rotation
	return 0.0

func _set_rotation(node: Node, r: float) -> void:
	## Set rotation on node
	if node is Node3D:
		node.rotation.y = r
	elif node is Node2D:
		node.rotation = r
	elif node is Control:
		node.rotation = r

func _get_scale(node: Node):
	## Get scale from node
	if node is Node3D:
		return node.scale
	elif node is Node2D:
		return node.scale
	elif node is Control:
		return node.scale
	return Vector2.ONE

func _set_scale(node: Node, s) -> void:
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

func _get_modulate(node: Node) -> Color:
	## Get modulate color (only for Node2D and Control)
	if node is Node2D:
		return node.modulate
	elif node is Control:
		return node.modulate
	return Color.WHITE

func _set_modulate(node: Node, c: Color) -> void:
	## Set modulate color (only for Node2D and Control)
	if node is Node2D:
		node.modulate = c
	elif node is Control:
		node.modulate = c

# ===== Effect Execution Methods =====

func execute_shake_position(target: Node, effect) -> void:
	var node = _get_target_node(target)
	if not node:
		return

	var original_pos = _get_position(node)
	var amplitude = effect.shake_amplitude * effect.intensity * 0.1
	var elapsed = 0.0

	while elapsed < effect.duration:
		var t = elapsed / effect.duration
		var decay = 1.0 - t
		var offset = Vector3.ZERO
		offset.x = randf_range(-1, 1) * amplitude * decay * effect.shake_axes.x
		offset.y = randf_range(-1, 1) * amplitude * decay * effect.shake_axes.y
		offset.z = randf_range(-1, 1) * amplitude * decay * effect.shake_axes.z

		if node is Node3D:
			_set_position(node, original_pos + offset)
		else:
			_set_position(node, original_pos + Vector2(offset.x, offset.y))

		await get_tree().process_frame
		elapsed += get_process_delta_time()

	_set_position(node, original_pos)

func execute_scale(target: Node, effect) -> void:
	var node = _get_target_node(target)
	if not node:
		return

	var tween = node.create_tween()
	var target_scale = effect.to_scale * effect.intensity
	tween.tween_property(node, "scale", target_scale, effect.duration)
	await tween.finished

func execute_color(target: Node, effect) -> void:
	var node = _get_target_node(target)
	if not node:
		return

	var tween = node.create_tween()
	var target_color = effect.to_color * effect.intensity
	tween.tween_property(node, "modulate", target_color, effect.duration)
	await tween.finished

func execute_flash(target: Node, effect) -> void:
	var node = _get_target_node(target)
	if not node:
		return

	var original = _get_modulate(node)
	_set_modulate(node, effect.flash_color * effect.intensity)
	await get_tree().create_timer(effect.duration).timeout
	_set_modulate(node, original)

func execute_freeze_frame(target: Node, effect) -> void:
	var original = Engine.time_scale
	Engine.time_scale = 0.0
	await get_tree().create_timer(effect.duration, true, false, true).timeout
	Engine.time_scale = original

func execute_hit_stop(target: Node, effect) -> void:
	var original = Engine.time_scale
	Engine.time_scale = 0.0
	await get_tree().create_timer(effect.duration, true, false, true).timeout
	Engine.time_scale = original
