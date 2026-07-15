@tool
extends VBoxContainer

## GFFPlayer custom Inspector section
## Displays CombosPanel as a custom control in the GFFPlayer inspector,
## without drawing the combo_dictionary property label.

signal open_timeline_requested(player: GFFPlayer)

var _panel: Control
var _player: GFFPlayer = null

func _init() -> void:
	_panel = preload("res://addons/game_feel_flow/editor/ui/combos_panel.tscn").instantiate()
	_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	# combos_panel sets its own minimum height and expands naturally with content.
	_panel.connect("open_timeline_requested", _on_open_timeline)
	add_child(_panel)


func set_player(player: GFFPlayer) -> void:
	_player = player
	if _panel.has_method("set_player"):
		_panel.set_player(player)


func _on_open_timeline() -> void:
	open_timeline_requested.emit(_player)
