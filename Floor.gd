extends CanvasLayer

const window_size = Vector2(640/32, 640/32)
var location = Vector2(0, 0);

func _ready():

	pass
	
func _add_floor():
	pass
	$FloorBox.rect_size = window_size*32
	$FloorBox.show()
	
func _add_wall(pos):
	var wall = preload("res://Wall.tscn").instance()
	wall.position = pos*32
	add_child(wall)
	
func _add_player():
	var player = preload("res://PlayerCharacter.tscn").instance()
	player.position = $StartPosition.position
	print(player.position)
	player.z_index = player.position.y
	add_child(player)
	player.show()
	
func _add_lava(pos):
	var lava = preload("res://Lava.tscn").instance()
	lava.position = pos*32
	add_child(lava)
	
func _generate_floor():
	_add_floor()
	var walledTiles = []
	var lavaTiles = []
	var possiblePlayerTiles = []
	
	for tile in range(window_size.x * window_size.y):
		var tileVector = Vector2(int(floor(tile/window_size.x)), tile % int(floor(window_size.x)))
		if randi() % 10 >= 5:  
			walledTiles.append(tileVector)
		elif randi() % 30 >= 6: 
			lavaTiles.append(tileVector)	
		else:
			possiblePlayerTiles.append(tileVector)			
	
			
	for wTile in walledTiles:
		_add_wall(wTile)		
	for lTile in lavaTiles:
		_add_lava(lTile)		
		
	possiblePlayerTiles.shuffle()
	
	print(possiblePlayerTiles[0])
	$StartPosition.position = possiblePlayerTiles[0]*32
	_add_player();
