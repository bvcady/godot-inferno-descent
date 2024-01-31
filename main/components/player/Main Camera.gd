extends Camera2D
# Called when the node enters the scene tree for the first time.
func _ready():
	drag_left_margin = 0.16
	drag_right_margin = 0.16
	drag_top_margin = 0.22
	drag_bottom_margin = 0.22
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = round(position)
	pass
