class_name GFFSound
extends GFFFeedback

## Game Feel Flow Sound Effect
##
## 音效播放效果

# ===== Properties =====
@export_group("Sound Settings")
@export var audio_stream: AudioStream
@export var volume_db: float = 0.0
@export var pitch_scale: float = 1.0
@export var pitch_random_range: float = 0.0

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)

	if not audio_stream:
		push_warning("GFFSound: No audio stream assigned")
		return

	# Create audio player
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = audio_stream
	audio_player.volume_db = volume_db + linear_to_db(intensity)
	audio_player.pitch_scale = pitch_scale + randf_range(-pitch_random_range, pitch_random_range)

	node.add_child(audio_player)
	audio_player.play()

	# Wait for audio to finish or duration
	var wait_time = max(audio_stream.get_length(), final_duration)
	await node.get_tree().create_timer(wait_time).timeout

	audio_player.queue_free()

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration