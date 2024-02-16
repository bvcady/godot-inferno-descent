extends StaticBody2D

class_name FloorTile
@export var noiseVal = 0.0
@export var color: Color = Color.TRANSPARENT

# Called when the node enters the scene tree for the first time.
func _ready():
	if color != Color.TRANSPARENT:
		$ColorRect.color = color


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
