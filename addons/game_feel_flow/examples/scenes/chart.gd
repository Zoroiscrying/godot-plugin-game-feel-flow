extends Control

## FPS chart control
## Draw FPS history curve and reference lines

var fps_history: Array[float] = []
var max_history: int = 100

func _draw() -> void:
	if fps_history.is_empty():
		return
	
	var width = size.x
	var height = size.y
	var step = width / max_history
	
	# Draw background
	draw_rect(Rect2(Vector2.ZERO, size), Color("#2d2d3f"))
	
	# Draw FPS line
	var points = PackedVector2Array()
	for i in range(fps_history.size()):
		var x = i * step
		var y = height - (fps_history[i] / 60.0 * height)
		points.append(Vector2(x, y))
	
	if points.size() > 1:
		draw_polyline(points, Color("#89b4fa"), 2.0)
	
	# Draw 60 FPS reference line
	var y60 = height - (60.0 / 60.0 * height)
	draw_line(Vector2(0, y60), Vector2(width, y60), Color("#a6e3a1"), 1.0)
	
	# Draw 30 FPS reference line
	var y30 = height - (30.0 / 60.0 * height)
	draw_line(Vector2(0, y30), Vector2(width, y30), Color("#f9e2af"), 1.0)

func update_data(history: Array[float], max: int) -> void:
	fps_history = history
	max_history = max
	queue_redraw()
