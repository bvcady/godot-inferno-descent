extends Button


# Called when the node enters the scene tree for the first time.

signal toggle_map;

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _pressed():
	emit_signal('toggle_map')
	pass
	
	
