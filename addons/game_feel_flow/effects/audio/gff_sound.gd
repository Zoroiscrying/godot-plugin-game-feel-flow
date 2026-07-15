@tool
class_name GFFSound
extends GFFEffect

## Game Feel Flow Sound Effect
##
## Sound effect playback

# ===== Properties =====
@export_group("Sound Settings")
@export var audio_stream: AudioStream
@export var volume_db: float = 0.0
@export var pitch_scale: float = 1.0
@export var pitch_random_range: float = 0.0

# ===== State =====
var _audio_player: AudioStreamPlayer = null

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)

	if not audio_stream:
		push_warning("GFFSound: No audio stream assigned")
		return

	# Create audio player
	_audio_player = AudioStreamPlayer.new()
	_audio_player.stream = audio_stream
	_audio_player.volume_db = volume_db + linear_to_db(intensity)
	_audio_player.pitch_scale = pitch_scale + randf_range(-pitch_random_range, pitch_random_range)

	node.add_child(_audio_player)
	_audio_player.play()

	# Wait for audio to finish or duration
	var wait_time = max(audio_stream.get_length(), final_duration)
	var tree := node.get_tree() if node and is_instance_valid(node) else Engine.get_main_loop()
	var timer: SceneTreeTimer
	if tree is SceneTree:
		timer = tree.create_timer(wait_time, true, false, true)
	else:
		timer = tree.create_timer(wait_time)
	while _is_playing and _audio_player.playing and timer.time_left > 0:
		await tree.process_frame

	if _is_playing and is_instance_valid(_audio_player):
		_audio_player.queue_free()
		_audio_player = null

func _stop() -> void:
	if is_instance_valid(_audio_player):
		_audio_player.stop()
		_audio_player.queue_free()
		_audio_player = null

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration