# addons/game_feel_flow/examples/components/showcase_chrome.gd
extends PanelContainer

@onready var title_label: Label = $Margin/HBox/TitleLabel
@onready var replay_btn: Button = $Margin/HBox/Replay
@onready var prev_btn: Button = $Margin/HBox/Prev
@onready var next_btn: Button = $Margin/HBox/Next
@onready var loop_check: CheckButton = $Margin/HBox/LoopCheck

var _controller: GFFShowcaseController

func bind_controller(c: GFFShowcaseController) -> void:
	_controller = c
	replay_btn.pressed.connect(c.replay)
	prev_btn.pressed.connect(c.prev_shot)
	next_btn.pressed.connect(c.next_shot)
	loop_check.button_pressed = c.loop_enabled
	loop_check.toggled.connect(func(on: bool) -> void: c.loop_enabled = on)
	c.shot_changed.connect(_on_shot_changed)
	c.chrome_visibility_changed.connect(func(v: bool) -> void: visible = v)
	visible = c.chrome_visible

func _on_shot_changed(_i: int, _id: String, title: String) -> void:
	title_label.text = title
