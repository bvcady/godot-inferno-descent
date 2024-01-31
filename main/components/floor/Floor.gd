extends StaticBody2D

class_name FloorTile
@export var noiseVal = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	noiseVal = noiseVal/10
	$ColorRect.color *= (1 - noiseVal);
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
