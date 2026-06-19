class_name GFFFlashTweener
extends GFFValueTweener

## Game Feel Flow Flash Tweener
##
## 闪烁变化

# ===== 属性 =====
var flash_color: Color = Color.WHITE
var flash_frequency: float = 15.0
var lerp_mode: int = 0  # 0=INSTANT, 1=LINEAR, 2=SMOOTH

func setup_from_params(params: GFFParams) -> void:
	## 从GFFParams中读取参数
	flash_color = params.get_color("color", flash_color)
	flash_frequency = params.get_float("frequency", flash_frequency)
	lerp_mode = params.get_int("lerp_mode", lerp_mode)

func tween_value(node: Node, target_function: GFFTargetFunction, from: Variant, to: Variant, duration: float, curve: Curve = null) -> void:
	var count = int(duration * flash_frequency)
	if count < 1:
		count = 1
	
	var interval = duration / count
	
	match lerp_mode:
		0:  # INSTANT
			for i in range(count):
				target_function.set_value(node, flash_color)
				await node.get_tree().create_timer(interval / 2).timeout
				target_function.set_value(node, from)
				await node.get_tree().create_timer(interval / 2).timeout
		1:  # LINEAR
			for i in range(count):
				var tween = node.create_tween()
				tween.tween_method(_apply_lerp.bind(node, target_function, from, flash_color), 0.0, 1.0, interval / 2)
				await tween.finished
				var tween2 = node.create_tween()
				tween2.tween_method(_apply_lerp.bind(node, target_function, flash_color, from), 0.0, 1.0, interval / 2)
				await tween2.finished
		2:  # SMOOTH
			for i in range(count):
				var tween = node.create_tween()
				tween.tween_method(_apply_lerp.bind(node, target_function, from, flash_color), 0.0, 1.0, interval / 2).set_ease(Tween.EASE_IN_OUT)
				await tween.finished
				var tween2 = node.create_tween()
				tween2.tween_method(_apply_lerp.bind(node, target_function, flash_color, from), 0.0, 1.0, interval / 2).set_ease(Tween.EASE_IN_OUT)
				await tween2.finished

func _apply_lerp(t: float, node: Node, target_function: GFFTargetFunction, from: Variant, to: Variant) -> void:
	if from is Color and to is Color:
		target_function.set_value(node, from.lerp(to, t))

func get_value_at_time(t: float, from: Variant, to: Variant, curve: Curve = null) -> Variant:
	return from
