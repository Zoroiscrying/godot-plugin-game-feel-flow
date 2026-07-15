@tool
class_name GFFAudioVolume
extends GFFEffect

## Game Feel Flow Audio Volume Effect
##
## Volume change effect supporting AudioStreamPlayer

# ===== Properties =====
@export_group("Audio Volume Settings")
@export var target_volume_db: float = -6.0
@export var volume_mode: VolumeMode = VolumeMode.TO_VOLUME

enum VolumeMode {
	TO_VOLUME,
	ADDITIVE,
	MULTIPLICATIVE
}

# ===== State =====
var _audio_node: Node = null
var _original_volume_db: float = 0.0

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	_audio_node = node
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var volume = params.get_float("volume", target_volume_db)

	if not node is AudioStreamPlayer and not node is AudioStreamPlayer2D and not node is AudioStreamPlayer3D:
		push_warning("GFFAudioVolume: Target is not an AudioStreamPlayer")
		return

	_original_volume_db = node.volume_db
	var target_volume: float

	match volume_mode:
		VolumeMode.TO_VOLUME:
			target_volume = volume * intensity
		VolumeMode.ADDITIVE:
			target_volume = _original_volume_db + volume * intensity
		VolumeMode.MULTIPLICATIVE:
			target_volume = _original_volume_db * volume * intensity

	var tween = node.create_tween()
	_register_active_tween(tween)
	if easing_curve:
		tween.tween_method(_apply_volume_curve.bind(node, _original_volume_db, target_volume), 0.0, 1.0, final_duration)
	else:
		tween.tween_property(node, "volume_db", target_volume, final_duration)
	await _await_tween(tween)

func _stop() -> void:
	if is_instance_valid(_audio_node):
		_audio_node.volume_db = _original_volume_db
	_audio_node = null

func _apply_volume_curve(t: float, node: Node, from: float, to: float) -> void:
	var value = easing_curve.sample(t)
	node.volume_db = lerp(from, to, value)

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration