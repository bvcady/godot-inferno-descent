extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	connect('health_changed', _on_health_changed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_health_changed(health: int):
	print('health changed')
	$ProgressBar.value = health
	pass # Replace with function body.
