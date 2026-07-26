extends Node2D

## Lightweight Click/Space combo demo (not the teaching path).
## For GFFPlayer + Combo onboarding, open `onboarding.tscn` instead.

@onready var player: GFFPlayer = $Icon/GFFPlayer
@onready var target: Sprite2D = $Icon

var _origin_position: Vector2 = Vector2.ZERO
var _origin_scale: Vector2 = Vector2.ONE


func _ready() -> void:
	# Register built-in Combos on this player's combo_dictionary.
	player.combo_dictionary["hit"] = GFFCombo.hit_light()
	player.combo_dictionary["explosion"] = GFFCombo.explosion_small()
	player.active_combo_key = "hit"
	_origin_position = target.position
	_origin_scale = target.scale


func _replay(combo_key: String) -> void:
	player.stop()
	target.position = _origin_position
	target.scale = _origin_scale
	target.modulate = Color.WHITE
	player.play(combo_key)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_replay("hit")

	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		_replay("explosion")
