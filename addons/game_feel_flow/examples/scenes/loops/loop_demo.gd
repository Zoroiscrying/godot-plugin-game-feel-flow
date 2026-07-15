extends Control

## Loop effect demos hub.
## Switch between individual loop demos with the dropdown at the top.
## Each demo is a standalone scene authored with GFFPlayer in the Inspector.

const DEMO_SCENES: Dictionary[String, String] = {
	"heartbeat": "res://addons/game_feel_flow/examples/scenes/loops/loop_heartbeat.tscn",
	"breathing": "res://addons/game_feel_flow/examples/scenes/loops/loop_breathing.tscn",
	"warning": "res://addons/game_feel_flow/examples/scenes/loops/loop_warning.tscn",
}

@onready var demo_selector: OptionButton = $VBoxContainer/TopBar/DemoSelector
@onready var viewport: SubViewport = $VBoxContainer/ViewportContainer/SubViewport

var _current_demo: Node = null
var _demo_names: Array[String] = []

func _ready() -> void:
	_demo_names = DEMO_SCENES.keys()
	for demo_name in _demo_names:
		demo_selector.add_item(demo_name.capitalize())
	demo_selector.item_selected.connect(_on_demo_selected)
	_load_demo(_demo_names[0])

func _load_demo(demo_name: String) -> void:
	if _current_demo:
		_stop_current_demo()
		_current_demo.queue_free()
		_current_demo = null

	var scene_path: String = DEMO_SCENES.get(demo_name, "")
	if scene_path.is_empty():
		return

	var scene: PackedScene = load(scene_path)
	if scene:
		_current_demo = scene.instantiate()
		viewport.add_child(_current_demo)

func _stop_current_demo() -> void:
	if not _current_demo:
		return
	# Stop any running GFFPlayer to avoid orphaned tweens and tree errors.
	var player = _current_demo.find_child("GFFPlayer", true, false)
	if player and player.has_method("stop"):
		player.stop()

func _on_demo_selected(index: int) -> void:
	if index >= 0 and index < _demo_names.size():
		_load_demo(_demo_names[index])
