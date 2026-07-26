extends Control

## Game scene sub-scene
## Effect demo simulating real game scenes

# ===== Node References =====
@onready var tab_container: TabContainer = $VBoxContainer/TabContainer
@onready var attack_scene: Control = $VBoxContainer/TabContainer/Attack
@onready var death_scene: Control = $VBoxContainer/TabContainer/Death
@onready var pickup_scene: Control = $VBoxContainer/TabContainer/Pickup
@onready var explosion_scene: Control = $VBoxContainer/TabContainer/Explosion
@onready var ui_scene: Control = $VBoxContainer/TabContainer/UI

# ===== Lifecycle =====

func _ready() -> void:
	_setup_attack_scene()
	_setup_death_scene()
	_setup_pickup_scene()
	_setup_explosion_scene()
	_setup_ui_scene()

# ===== Attack Scene =====

func _setup_attack_scene() -> void:
	var player = _create_character("Player", Vector2(200, 300))
	var enemy = _create_character("Enemy", Vector2(600, 300))

	var hit_light_btn = Button.new()
	hit_light_btn.text = "Hit Light"
	hit_light_btn.pressed.connect(func(): _replay_combo(enemy, "hit_light"))

	var hit_heavy_btn = Button.new()
	hit_heavy_btn.text = "Hit Heavy"
	hit_heavy_btn.pressed.connect(func(): _replay_combo(enemy, "hit_heavy"))

	var hbox = HBoxContainer.new()
	hbox.add_child(hit_light_btn)
	hbox.add_child(hit_heavy_btn)
	hbox.position = Vector2(350, 500)

	attack_scene.add_child(player)
	attack_scene.add_child(enemy)
	attack_scene.add_child(hbox)

# ===== Death Scene =====

func _setup_death_scene() -> void:
	var enemy = _create_character("Enemy", Vector2(400, 300))

	var death_btn = Button.new()
	death_btn.text = "Death"
	death_btn.pressed.connect(func(): _replay_combo(enemy, "death"))
	death_btn.position = Vector2(350, 500)

	death_scene.add_child(enemy)
	death_scene.add_child(death_btn)

# ===== Pickup Scene =====

func _setup_pickup_scene() -> void:
	var player = _create_character("Player", Vector2(200, 300))
	var item = _create_item("Item", Vector2(600, 300))

	var pickup_btn = Button.new()
	pickup_btn.text = "Pickup"
	pickup_btn.pressed.connect(func(): _replay_combo(item, "pickup"))
	pickup_btn.position = Vector2(350, 500)

	pickup_scene.add_child(player)
	pickup_scene.add_child(item)
	pickup_scene.add_child(pickup_btn)

# ===== Explosion Scene =====

func _setup_explosion_scene() -> void:
	var target = _create_character("Target", Vector2(400, 300))

	var explosion_btn = Button.new()
	explosion_btn.text = "Explosion"
	explosion_btn.pressed.connect(func(): _replay_combo(target, "explosion"))
	explosion_btn.position = Vector2(350, 500)

	explosion_scene.add_child(target)
	explosion_scene.add_child(explosion_btn)

# ===== UI Feedback Scene =====

func _setup_ui_scene() -> void:
	var button := Button.new()
	button.text = "Click Me"
	button.position = Vector2(300, 200)
	var button_origin: Vector2 = button.scale
	button.pressed.connect(func():
		GameFeelFlow.stop_all(button)
		button.scale = button_origin
		GameFeelFlow.play("scale", button)
	)

	var progress = ProgressBar.new()
	progress.value = 50
	progress.position = Vector2(300, 300)
	progress.size = Vector2(200, 30)

	var animate_btn = Button.new()
	animate_btn.text = "Animate Progress"
	animate_btn.position = Vector2(300, 400)
	animate_btn.pressed.connect(func():
		var tween = create_tween()
		tween.tween_property(progress, "value", 100, 0.5)
		tween.tween_property(progress, "value", 0, 0.5)
	)

	ui_scene.add_child(button)
	ui_scene.add_child(progress)
	ui_scene.add_child(animate_btn)

# ===== Helpers =====

func _replay_combo(target: Node2D, combo_name: String) -> void:
	GameFeelFlow.stop_all(target)
	target.position = target.get_meta("gff_origin", target.position)
	target.scale = Vector2.ONE
	target.modulate = Color.WHITE
	Engine.time_scale = 1.0
	GameFeelFlow.play_combo(combo_name, target)

func _create_character(character_name: String, char_position: Vector2) -> Node2D:
	var character = Node2D.new()
	character.name = character_name
	character.position = char_position
	character.set_meta("gff_origin", char_position)

	var sprite = ColorRect.new()
	sprite.size = Vector2(50, 80)
	sprite.color = Color.BLUE if character_name == "Player" else Color.RED
	sprite.position = Vector2(-25, -40)
	character.add_child(sprite)

	var label = Label.new()
	label.text = character_name
	label.position = Vector2(-20, -60)
	character.add_child(label)

	return character

func _create_item(item_name: String, item_position: Vector2) -> Node2D:
	var item = Node2D.new()
	item.name = item_name
	item.position = item_position
	item.set_meta("gff_origin", item_position)

	var sprite = ColorRect.new()
	sprite.size = Vector2(30, 30)
	sprite.color = Color.YELLOW
	sprite.position = Vector2(-15, -15)
	item.add_child(sprite)

	return item