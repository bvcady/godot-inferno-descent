extends StaticBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	_defineWallSize()
	pass
	

func _defineWallSize():
	if(randi()%50 > 40):
		$High.show();
		return
	if(randi()%50 < 10):
		$Low.show();
		return
	else: 
		$Middle.show();
		return

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
