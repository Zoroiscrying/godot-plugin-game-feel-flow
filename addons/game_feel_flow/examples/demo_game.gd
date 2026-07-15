extends Node2D

## Game Feel Flow Game Demo
##
## Simulates real game scenes, showcasing practical effect usage

# ===== Node References =====
@onready var player: Node2D = $Player
@onready var enemy: Node2D = $Enemy
@onready var item: Node2D = $Item
@onready var ui_label: Label = $UI/Label
@onready var ui_progress: ProgressBar = $UI/ProgressBar

# ===== Game State =====
var player_health: int = 100
var enemy_health: int = 100
var score: int = 0

# ===== Lifecycle =====

func _ready() -> void:
	print("=== Game Feel Flow Game Demo ===")
	print("")
	print("Controls:")
	print("  Left Click: Attack enemy")
	print("  Right Click: Pickup item")
	print("  Space: Special attack")
	print("  R: Reset")
	
	_update_ui()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				_attack_enemy()
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				_pickup_item()
	elif event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_SPACE:
				_special_attack()
			elif event.keycode == KEY_R:
				_reset_game()

# ===== Game Logic =====

func _attack_enemy() -> void:
	if enemy_health <= 0:
		return
	
	# Play attack effect
	GFUtil.hit(enemy, 1.0)
	
	# Deal damage
	var damage = randi_range(10, 20)
	enemy_health = max(0, enemy_health - damage)
	
	# Show damage number
	_show_damage_number(enemy.position, damage)
	
	# Check if enemy died
	if enemy_health <= 0:
		_enemy_death()
	
	_update_ui()

func _pickup_item() -> void:
	# Play pickup effect
	GFUtil.pickup(item, 1.0)
	
	# Add score
	score += 10
	
	# Hide item
	item.visible = false
	
	# Re-show item after delay
	await get_tree().create_timer(2.0).timeout
	item.visible = true
	
	_update_ui()

func _special_attack() -> void:
	if enemy_health <= 0:
		return
	
	# Play explosion effect
	GFUtil.explosion(enemy, 1.0)
	
	# Deal massive damage
	var damage = randi_range(30, 50)
	enemy_health = max(0, enemy_health - damage)
	
	# Show damage number
	_show_damage_number(enemy.position, damage)
	
	# Check if enemy died
	if enemy_health <= 0:
		_enemy_death()
	
	_update_ui()

func _enemy_death() -> void:
	# Play death effect
	GFUtil.death(enemy, 1.0)
	
	# Add score
	score += 50
	
	# Respawn enemy after delay
	await get_tree().create_timer(3.0).timeout
	enemy_health = 100
	enemy.visible = true
	enemy.modulate = Color.WHITE
	
	_update_ui()

func _show_damage_number(position: Vector2, damage: int) -> void:
	# Create damage number label
	var label = Label.new()
	label.text = str(damage)
	label.position = position + Vector2(randf_range(-20, 20), -50)
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color.RED)
	add_child(label)
	
	# Animate damage number display
	var tween = create_tween()
	tween.tween_property(label, "position:y", label.position.y - 50, 0.5)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(label.queue_free)

func _reset_game() -> void:
	player_health = 100
	enemy_health = 100
	score = 0
	enemy.visible = true
	enemy.modulate = Color.WHITE
	item.visible = true
	_update_ui()
	print("Game Reset")

# ===== UI Update =====

func _update_ui() -> void:
	if ui_label:
		ui_label.text = "Health: %d | Enemy: %d | Score: %d" % [player_health, enemy_health, score]
	if ui_progress:
		ui_progress.value = enemy_health
