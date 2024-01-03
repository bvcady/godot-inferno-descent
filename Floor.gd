extends CanvasLayer

const level_size = Vector2(8, 8)
const cell_size = Vector2(32,32)
var location = Vector2(0, 0);
var grid = []

func _ready():
	pass
	
func world_to_grid(world_position):
	return Vector2(	
		int(world_position.x / cell_size.x),
		int(world_position.y / cell_size.y)
	)

func _is_valid_move(target_cell):
	target_cell.x >= 0 && target_cell.x < level_size.x && target_cell.y >= 0 && target_cell.y < level_size.y && grid[target_cell.y][target_cell.x] == 'empty'  # Assuming 0 is empty

func grid_to_world(grid_position):
	return Vector2(
		grid_position.x * cell_size.x,
		grid_position.y * cell_size.y
	)
	
func _add_floor():
	for i in range(level_size.y):
		var row = []
		for j in range(level_size.x):
			row.append('empty')
		grid.append(row)
	
	$FloorBox.size = level_size*cell_size
	$FloorBox.show()
	
func _add_wall(pos):
	var wall = preload("res://Wall.tscn").instantiate()
	grid[pos.y][pos.x] = 'wall'
	wall.position = pos*cell_size
	add_child(wall)
	
func _add_player(initial_position):
	var player = preload("res://PlayerCharacter.tscn").instantiate()
	player.position = initial_position + Vector2(16,0)
	add_child(player)

	player.start(Vector2(level_size.x * cell_size.x,  level_size.y * cell_size.y))
	
func _add_lava(pos):
	var lava = preload("res://Lava.tscn").instantiate()
	grid[pos.y][pos.x] = 'lava'
	lava.position = pos*cell_size
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
	
	_add_player(possiblePlayerTiles[0]*cell_size);
