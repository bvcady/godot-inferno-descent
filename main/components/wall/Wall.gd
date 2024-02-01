@tool
extends StaticBody2D

class_name Wall

enum Height {Low, Middle, High}

@export var normalPosition = Vector2(0, 0)
@export var height: Height
@export var noiseVal = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$High.hide()
	$Middle.hide()
	$Low.hide()
	_defineWallHeight()
	pass

func _defineWallHeight():
	
	if noiseVal > 0.85 : 
		height = Height.High
	elif noiseVal > 0.7 : 
		height = Height.Middle
	else:
		height = Height.Low
		
	if(height == Height.High):
		$High.show();
		return
	elif(height == Height.Middle):
		$Middle.show();
		return
	else: 
		$Low.show();
		return

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
