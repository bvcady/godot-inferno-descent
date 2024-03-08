extends Camera2D
# Called when the node enters the scene tree for the first time.

@export var target_zoom: float = 3.0
@export var zoomed: bool = false

func _ready():
	drag_left_margin = 0.08
	drag_right_margin = 0.08
	drag_top_margin = 0.08
	drag_bottom_margin =  0.08
	position_smoothing_enabled = false;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not position_smoothing_enabled: 
		position_smoothing_enabled = true
	zoom = zoom.lerp(Vector2(target_zoom, target_zoom), 0.003)
	pass
