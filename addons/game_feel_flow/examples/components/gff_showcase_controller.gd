# addons/game_feel_flow/examples/components/gff_showcase_controller.gd
@tool
class_name GFFShowcaseController
extends Node

signal shot_changed(index: int, id: String, title: String)
signal chrome_visibility_changed(visible: bool)

var shots: Array = []  # Array of Dictionaries
var current_index: int = 0
var loop_enabled: bool = true
var chrome_visible: bool = true

func set_shots(new_shots: Array) -> void:
	stop_current()
	shots = new_shots
	current_index = 0

func play_current() -> void:
	if shots.is_empty():
		return
	var shot: Dictionary = shots[current_index]
	if shot.has("start") and shot["start"] is Callable:
		shot["start"].call()
	shot_changed.emit(current_index, str(shot.get("id", "")), str(shot.get("title", "")))

func stop_current() -> void:
	if shots.is_empty() or current_index < 0 or current_index >= shots.size():
		return
	var shot: Dictionary = shots[current_index]
	if shot.has("stop") and shot["stop"] is Callable:
		shot["stop"].call()

func next_shot() -> void:
	if shots.is_empty():
		return
	stop_current()
	current_index = (current_index + 1) % shots.size()
	play_current()

func prev_shot() -> void:
	if shots.is_empty():
		return
	stop_current()
	current_index = (current_index - 1 + shots.size()) % shots.size()
	play_current()

func replay() -> void:
	stop_current()
	play_current()

func set_chrome_visible(visible: bool) -> void:
	chrome_visible = visible
	chrome_visibility_changed.emit(chrome_visible)

func toggle_chrome() -> void:
	set_chrome_visible(not chrome_visible)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_H:
			toggle_chrome()
			get_viewport().set_input_as_handled()
