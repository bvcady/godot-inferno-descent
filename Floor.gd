extends CanvasLayer

const level_size = Vector2(40, 50)
var location = Vector2(0, 0);

func _ready():

	pass
	
func _add_floor():
	pass
	$FloorBox.size = level_size*32
	$FloorBox.show()
	
func _add_wall(pos):
	var wall = preload("res://Wall.tscn").instantiate()
	wall.position = pos*32
	add_child(wall)
	
func _add_player():
	var player = preload("res://PlayerCharacter.tscn").instantiate()
	player.position = $StartPosition.position + Vector2(16,16)

	player.z_index = player.position.y
	add_child(player)

	player.start(Vector2(level_size.x * 32,  level_size.y * 32))
	
func _add_lava(pos):
	var lava = preload("res://Lava.tscn").instantiate()
	lava.position = pos*32
	add_child(lava)
	
func _generate_floor():
	_add_floor()
	var walledTiles = []
	var lavaTiles = []
	var possiblePlayerTiles = []
	
	for tile in range(level_size.x * level_size.y):
		var tileVector = Vector2(int(floor(tile/level_size.x)), tile % int(floor(level_size.x)))
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

	$StartPosition.position = possiblePlayerTiles[0]*32
	_add_player();
