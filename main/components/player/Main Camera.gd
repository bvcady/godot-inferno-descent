extends Camera2D
# Called when the node enters the scene tree for the first time.

@export var target_zoom: int = 2
@export_range(0.01, 0.1) var zoom_speed
@export var zoomed: bool = false

func _ready():
	drag_left_margin = 32 / get_viewport_rect().size.x * 2 * target_zoom
	drag_right_margin = 32 / get_viewport_rect().size.x * 2 * target_zoom
	drag_top_margin = 32 / get_viewport_rect().size.y * 2 * target_zoom
	drag_bottom_margin = 32 / get_viewport_rect().size.y * 2 * target_zoom
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var nZoom = (target_zoom - zoom.x) * zoom_speed
	zoom = zoom + Vector2(nZoom, nZoom)
	pass
