class_name GFFAnimator
extends GFFFeedback

## Game Feel Flow Animator Effect
##
## 动画播放效果，支持AnimationPlayer

# ===== Properties =====
@export_group("Animator Settings")
@export var animation_name: String = ""
@export var playback_speed: float = 1.0
@export var from_end: bool = false

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var anim_name = params.get_string("animation", animation_name)

	# Find AnimationPlayer
	var anim_player: AnimationPlayer = null
	if node is AnimationPlayer:
		anim_player = node
	else:
		anim_player = node.get_node_or_null("AnimationPlayer")
		if not anim_player:
			for child in node.get_children():
				if child is AnimationPlayer:
					anim_player = child
					break

	if not anim_player:
		push_warning("GFFAnimator: No AnimationPlayer found")
		return

	if anim_name.is_empty():
		push_warning("GFFAnimator: No animation name specified")
		return

	if not anim_player.has_animation(anim_name):
		push_warning("GFFAnimator: Animation '", anim_name, "' not found")
		return

	# Play animation
	anim_player.play(anim_name, -1, playback_speed * intensity, from_end)

	# Wait for animation
	var animation = anim_player.get_animation(anim_name)
	if animation:
		var wait_time = animation.length / (playback_speed * intensity)
		await node.get_tree().create_timer(wait_time).timeout

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration