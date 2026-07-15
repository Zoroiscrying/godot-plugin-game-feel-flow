extends Node2D

## Test scene script
## For testing Game Feel Flow effects

@onready var target: ColorRect = $Target

func _ready() -> void:
	print("Test Scene Ready - Click target to test effects")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_test_effect()

func _test_effect() -> void:
	# Test effect
	GameFeelFlow.play("shake", target)
