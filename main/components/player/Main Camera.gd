extends Camera2D
# Called when the node enters the scene tree for the first time.

@export var target_zoom: int = 2
@export_range(0.01, 0.1) var zoom_speed
@export var zoomed: bool = false

func _ready():
	drag_left_margin = 0.16
	drag_right_margin = 0.16
	drag_top_margin = 0.22
	drag_bottom_margin = 0.22
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var nZoom = (target_zoom - zoom.x) * zoom_speed
	zoom = zoom + Vector2(nZoom, nZoom)
	pass
