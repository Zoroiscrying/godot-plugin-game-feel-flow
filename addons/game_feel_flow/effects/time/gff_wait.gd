@tool
class_name GFFWait
extends GFFEffect

## Wait/delay effect: does nothing for a specified duration, used to arrange time intervals.

@export_group("Wait Settings")
@export var wait_duration: float = 0.5


func _execute(node: Node, params: GFFParams) -> void:
	var final_duration := params.duration
	if final_duration <= 0.0:
		final_duration = wait_duration

	var tree := node.get_tree() if node and is_instance_valid(node) else Engine.get_main_loop()
	var timer: SceneTreeTimer
	if tree is SceneTree:
		timer = tree.create_timer(final_duration, true, false, true)
	else:
		timer = tree.create_timer(final_duration)
	while _is_playing and timer.time_left > 0:
		await tree.process_frame
