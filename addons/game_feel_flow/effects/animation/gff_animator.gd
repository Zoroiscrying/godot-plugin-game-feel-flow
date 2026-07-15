@tool
class_name GFFAnimator
extends GFFEffect

## Game Feel Flow Animator Effect
##
## Animation playback effect supporting AnimationPlayer

# ===== Properties =====
@export_group("Animator Settings")
@export var animation_name: String = ""
@export var playback_speed: float = 1.0
@export var from_end: bool = false

# ===== State =====
var _anim_player: AnimationPlayer = null

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var anim_name = params.get_string("animation", animation_name)

	# Find AnimationPlayer
	_anim_player = null
	if node is AnimationPlayer:
		_anim_player = node
	else:
		_anim_player = node.get_node_or_null("AnimationPlayer")
		if not _anim_player:
			for child in node.get_children():
				if child is AnimationPlayer:
					_anim_player = child
					break

	if not _anim_player:
		push_warning("GFFAnimator: No AnimationPlayer found")
		return

	if anim_name.is_empty():
		push_warning("GFFAnimator: No animation name specified")
		return

	if not _anim_player.has_animation(anim_name):
		push_warning("GFFAnimator: Animation '", anim_name, "' not found")
		return

	# Play animation
	_anim_player.play(anim_name, -1, playback_speed * intensity, from_end)

	# Wait for animation
	var animation = _anim_player.get_animation(anim_name)
	if animation:
		var wait_time = animation.length / (playback_speed * intensity)
		var tree := node.get_tree() if node and is_instance_valid(node) else Engine.get_main_loop()
		var timer: SceneTreeTimer
		if tree is SceneTree:
			timer = tree.create_timer(wait_time, true, false, true)
		else:
			timer = tree.create_timer(wait_time)
		while _is_playing and _anim_player.is_playing() and timer.time_left > 0:
			await tree.process_frame

func _stop() -> void:
	if is_instance_valid(_anim_player) and _anim_player.is_playing():
		_anim_player.stop()
	_anim_player = null

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration