class_name GFFAudioVolume
extends GFFFeedback

## Game Feel Flow Audio Volume Effect
##
## 音量变化效果，支持AudioStreamPlayer

# ===== Properties =====
@export_group("Audio Volume Settings")
@export var target_volume_db: float = -6.0
@export var volume_mode: VolumeMode = VolumeMode.TO_VOLUME

enum VolumeMode {
	TO_VOLUME,
	ADDITIVE,
	MULTIPLICATIVE
}

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var volume = params.get_float("volume", target_volume_db)

	if not node is AudioStreamPlayer and not node is AudioStreamPlayer2D and not node is AudioStreamPlayer3D:
		push_warning("GFFAudioVolume: Target is not an AudioStreamPlayer")
		return

	var original_volume = node.volume_db
	var target_volume: float

	match volume_mode:
		VolumeMode.TO_VOLUME:
			target_volume = volume * intensity
		VolumeMode.ADDITIVE:
			target_volume = original_volume + volume * intensity
		VolumeMode.MULTIPLICATIVE:
			target_volume = original_volume * volume * intensity

	if easing_curve:
		var tween = node.create_tween()
		tween.tween_method(_apply_volume_curve.bind(node, original_volume, target_volume), 0.0, 1.0, final_duration)
		await tween.finished
	else:
		var tween = node.create_tween()
		tween.tween_property(node, "volume_db", target_volume, final_duration)
		await tween.finished

func _apply_volume_curve(t: float, node: Node, from: float, to: float) -> void:
	var value = easing_curve.sample(t)
	node.volume_db = lerp(from, to, value)

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration