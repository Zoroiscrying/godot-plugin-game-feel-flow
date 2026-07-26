@tool
class_name GFFFlashTweener
extends GFFTweener

enum LerpMode { INSTANT, LINEAR, SMOOTH }

const FLASH_SHADER := preload("res://addons/game_feel_flow/shaders/gff_canvas_flash.gdshader")

@export var flash_color: Color = Color.WHITE
@export var frequency: float = 15.0
@export var lerp_mode: LerpMode = LerpMode.INSTANT

## Backups for every CanvasItem we temporarily re-materialize (parent + drawable children).
var _material_backups: Array = [] # Dictionary{item, material}
var _owned_materials: Array[ShaderMaterial] = []
var _flash_host: Node = null


func get_tweener_name() -> String:
	return "Flash"


func get_supported_value_types() -> Array[GFFValueType.Value]:
	return [GFFValueType.Value.COLOR]


func apply_params(params: GFFParams) -> void:
	if params == null:
		return
	var color_variant: Variant = params.get_variant("flash_color", null)
	if color_variant == null:
		color_variant = params.get_variant("color", null)
	if color_variant is Color:
		flash_color = color_variant
	frequency = params.get_float("frequency", frequency)


func tween_node(node: Node, target: GFFTarget, from: Variant, to: Variant, duration: float, curve: Curve = null) -> void:
	_is_stopped = false
	# CanvasItem tree: bleach via shader (modulate cannot turn a white sprite white).
	# Apply on drawable descendants — parent Node2D modulate cascades, but materials do not.
	if node is CanvasItem:
		await _tween_canvas_flash(node, duration)
		return
	# Fallback for non-canvas nodes: multiply modulate (legacy path).
	await _tween_modulate_flash(node, target, from, duration)


func stop() -> void:
	super.stop()
	_cleanup_flash_material()


func _tween_canvas_flash(host: Node, duration: float) -> void:
	_install_flash_materials(host)
	if _owned_materials.is_empty():
		# No drawable canvas items — fall back to modulate on host.
		if host is CanvasItem and host.get("modulate") != null:
			var color_target := GFFColorTarget.new()
			await _tween_modulate_flash(host, color_target, (host as CanvasItem).modulate, duration)
		return
	var count := maxi(1, int(duration * frequency))
	var interval := duration / float(count)
	var tree := host.get_tree()
	for i in range(count):
		if _is_stopped or not is_instance_valid(host):
			break
		match lerp_mode:
			LerpMode.INSTANT:
				_set_flash_amount(1.0)
				await tree.create_timer(interval / 2.0, true, false, true).timeout
				if _is_stopped or not is_instance_valid(host):
					break
				_set_flash_amount(0.0)
				await tree.create_timer(interval / 2.0, true, false, true).timeout
			LerpMode.LINEAR, LerpMode.SMOOTH:
				await _amount_tween(host, 0.0, 1.0, interval / 2.0)
				if _is_stopped or not is_instance_valid(host):
					break
				await _amount_tween(host, 1.0, 0.0, interval / 2.0)
	_cleanup_flash_material()


func _tween_modulate_flash(node: Node, target: GFFTarget, from: Variant, duration: float) -> void:
	var count := maxi(1, int(duration * frequency))
	var interval := duration / float(count)
	for i in range(count):
		if _is_stopped or not is_instance_valid(node):
			return
		match lerp_mode:
			LerpMode.INSTANT:
				target.apply_value(node, flash_color)
				await node.get_tree().create_timer(interval / 2.0, true, false, true).timeout
				if _is_stopped or not is_instance_valid(node):
					return
				target.apply_value(node, from)
				await node.get_tree().create_timer(interval / 2.0, true, false, true).timeout
			LerpMode.LINEAR, LerpMode.SMOOTH:
				await _flash_tween(node, target, from, flash_color, interval / 2.0, Tween.EASE_IN_OUT)
				if _is_stopped or not is_instance_valid(node):
					return
				await _flash_tween(node, target, flash_color, from, interval / 2.0, Tween.EASE_IN_OUT)


func _flash_tween(node: Node, target: GFFTarget, from: Color, to: Color, duration: float, ease_type: int) -> void:
	var tween = _start_tween(node)
	tween.tween_method(_apply_lerp.bind(node, target, from, to), 0.0, 1.0, duration).set_ease(ease_type)
	await _tween_completed


func _apply_lerp(t: float, node: Node, target: GFFTarget, from: Color, to: Color) -> void:
	target.apply_value(node, from.lerp(to, t))


func _amount_tween(host: Node, from_amount: float, to_amount: float, duration: float) -> void:
	var tween = _start_tween(host)
	tween.tween_method(_set_flash_amount, from_amount, to_amount, duration)
	await _tween_completed


func _install_flash_materials(host: Node) -> void:
	_cleanup_flash_material()
	_flash_host = host
	for item in _collect_drawable_canvas_items(host):
		var mat := ShaderMaterial.new()
		mat.shader = FLASH_SHADER
		mat.set_shader_parameter("flash_color", flash_color)
		mat.set_shader_parameter("flash_amount", 0.0)
		_material_backups.append({"item": item, "material": item.material})
		_owned_materials.append(mat)
		item.material = mat


func _collect_drawable_canvas_items(node: Node) -> Array[CanvasItem]:
	var items: Array[CanvasItem] = []
	if node is Sprite2D or node is AnimatedSprite2D or node is TextureRect or node is MeshInstance2D or node is Polygon2D:
		items.append(node as CanvasItem)
	for child in node.get_children():
		items.append_array(_collect_drawable_canvas_items(child))
	# Fallback: host itself if nothing drawable found underneath.
	if items.is_empty() and node is CanvasItem:
		items.append(node as CanvasItem)
	return items


func _set_flash_amount(amount: float) -> void:
	for mat in _owned_materials:
		if mat:
			mat.set_shader_parameter("flash_amount", amount)
			mat.set_shader_parameter("flash_color", flash_color)


func _cleanup_flash_material() -> void:
	for entry in _material_backups:
		var item: CanvasItem = entry.get("item")
		if is_instance_valid(item):
			item.material = entry.get("material")
	_material_backups.clear()
	_owned_materials.clear()
	_flash_host = null
