extends Node2D

## 测试场景脚本
## 用于测试Game Feel Flow效果

@onready var target: ColorRect = $Target

func _ready() -> void:
	print("Test Scene Ready - Click target to test effects")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_test_effect()

func _test_effect() -> void:
	# 测试效果
	GameFeelFlow.play("shake", target)
