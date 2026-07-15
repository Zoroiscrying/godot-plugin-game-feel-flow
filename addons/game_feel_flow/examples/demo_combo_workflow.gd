extends Node2D

## Demo: configure and trigger Game Feel using combo_dictionary workflow

@onready var player: GFFPlayer = $GFFPlayer
@onready var target: Sprite2D = $Icon

func _ready() -> void:
	# Register built-in Combos to GFFPlayer's combo_dictionary via code
	player.combo_dictionary["hit"] = GFFCombo.hit_light()
	player.combo_dictionary["explosion"] = GFFCombo.explosion_small()
	player.active_combo_key = "hit"

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		player.play("hit")
		target.modulate = Color.WHITE

	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		player.play("explosion")

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		player.play("hit")
