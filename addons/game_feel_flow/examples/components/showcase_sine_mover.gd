class_name GFFShowcaseSineMover
extends Node

## Independent sine bob for showcase freeze demos.
## Uses [_process] delta so Engine.time_scale=0 (freeze_frame) pauses motion
## without involving GameFeelFlow tweens.

@export var target_path: NodePath
@export var amplitude: float = 90.0
@export var frequency_hz: float = 1.6

var enabled: bool = false
var _t: float = 0.0
var _origin: Vector2 = Vector2.ZERO


func start_motion() -> void:
	var node := _target()
	if node == null:
		return
	_origin = node.position
	_t = 0.0
	enabled = true


func stop_motion(reset_position: bool = true) -> void:
	enabled = false
	_t = 0.0
	if reset_position:
		var node := _target()
		if node:
			node.position = _origin


func set_origin_from_target() -> void:
	var node := _target()
	if node:
		_origin = node.position


func _process(delta: float) -> void:
	if not enabled:
		return
	var node := _target()
	if node == null:
		return
	# delta is 0 while freeze_frame holds Engine.time_scale at 0.
	_t += delta
	node.position.y = _origin.y + sin(_t * TAU * frequency_hz) * amplitude


func _target() -> Node2D:
	if target_path.is_empty():
		return null
	return get_node_or_null(target_path) as Node2D
