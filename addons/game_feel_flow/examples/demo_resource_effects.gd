extends Node2D

## Game Feel Flow Resource-based Effects Demo

@onready var sprite: ColorRect = $Sprite2D

func _ready() -> void:
	print("=== Game Feel Flow - Effects Demo ===")
	print("")
	print("Press keys to play effects:")
	print("")
	print("--- Single Effects ---")
	print("1 - Shake")
	print("2 - Scale")
	print("3 - Flash")
	print("4 - Freeze Frame")
	print("")
	print("--- Hit Effects ---")
	print("Q - Hit Light")
	print("W - Hit Medium")
	print("E - Hit Heavy")
	print("R - Hit Critical")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				_play_shake()
			KEY_2:
				_play_scale()
			KEY_3:
				_play_flash()
			KEY_4:
				_play_freeze()
			KEY_Q:
				_play_hit(1.0, 0.3)
			KEY_W:
				_play_hit(1.5, 0.4)
			KEY_E:
				_play_hit(2.0, 0.5)
			KEY_R:
				_play_hit(3.0, 0.6)

# ===== Single Effects =====

func _play_shake() -> void:
	print("Playing shake...")
	GameFeelFlow.play("shake", sprite, {"amplitude": 10.0, "duration": 0.3})

func _play_scale() -> void:
	print("Playing scale...")
	GameFeelFlow.play("scale", sprite, {"duration": 0.3})

func _play_flash() -> void:
	print("Playing flash...")
	GameFeelFlow.play("flash", sprite, {"color": Color.WHITE, "duration": 0.1})

func _play_freeze() -> void:
	print("Playing freeze...")
	GameFeelFlow.play("freeze_frame", null, {"duration": 0.1})

# ===== Hit Effects =====

func _play_hit(intensity: float, duration: float) -> void:
	print("Playing hit with intensity: ", intensity)
	GameFeelFlow.play_combo("hit_light", sprite, {"intensity": intensity, "duration": duration})
