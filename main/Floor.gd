@tool

extends CanvasLayer

const level_size = Vector2(5, 5)
const cell_size = Vector2(32,32)
var location = Vector2(0, 0);
var grid = [];
var wallNoise: FastNoiseLite
var lavaNoise: FastNoiseLite;

func _ready():
	hide()
	wallNoise = preload("res://main/components/wall/WallsNoise.tres");
	lavaNoise = wallNoise.duplicate(false)

	wallNoise.seed = randi()
	lavaNoise.seed = randi()

	for i in range(level_size.y):
		var row = []
		for j in range(level_size.x):
			row.append('floor')
		grid.append(row)
	
	_generate_floor()
	follow_viewport_enabled = true;
	pass
	
func getNormalizedNoise(noise: FastNoiseLite, x: float, y: float):
	return getNormalizedNoise2d(noise, Vector2(x, y))
	pass

func getNormalizedNoise2d(noise: FastNoiseLite, pos: Vector2):
	return (1 + noise.get_noise_2dv(pos)) / 2;
	pass
	
func world_to_grid(world_position):
	return Vector2(	
		int(world_position.x / cell_size.x),
		int(world_position.y / cell_size.y)
	)

func _is_valid_move(target_cell):
	var valid_tile = target_cell.x >= 0 && target_cell.x < level_size.x && target_cell.y >= 0 && target_cell.y < level_size.y
	if valid_tile:
		if(grid[target_cell.y][target_cell.x] != 'wall'):
			return true
	return false
	
func grid_to_world(grid_position):
	return Vector2(
		grid_position.x * cell_size.x,
		grid_position.y * cell_size.y
	)
	
func _add_floor(pos):
	var floor = preload("res://main/components/floor/Floor.tscn").instantiate()
	floor.position = pos*cell_size
	floor.noiseVal = getNormalizedNoise2d(wallNoise, pos);
	$FloorGroup.add_child(floor)
	
func _add_wall(pos):
	var wall = preload("res://main/components/wall/Wall.tscn").instantiate()

	var wN = getNormalizedNoise2d(wallNoise, pos);
	wall.noiseVal = wN;
	
	grid[pos.y][pos.x] = 'wall'
	
	wall.normalPosition = pos
	wall.position = pos*cell_size
	
	if wN > 0.85 : 
		wall.height = wall.Height.High
	elif wN > 0.7 : 
		wall.height = wall.Height.Middle
	else:
		wall.height = wall.Height.Low

	
	var skeleton = preload("res://main/components/Skeleton.tscn").instantiate()
	var skelVal = getNormalizedNoise2d(wallNoise, pos);
	
	if(skelVal > 0.8 && skelVal < 0.85):
		wall.add_child(skeleton)
		
	$DrawGroup.add_child(wall)
	
	_add_floor(pos)
	
func _add_player(initial_position):
	var player = $DrawGroup/PlayerCharacter
	player.hide()
	player.normalPosition = initial_position
	player.position = initial_position*cell_size 

	player.start(Vector2(level_size.x * cell_size.x,  level_size.y * cell_size.y))
	
func _add_lava(pos):
	_add_floor(pos)
	var lava = preload("res://main/components/lava/Lava.tscn").instantiate()
	grid[pos.y][pos.x] = 'lava'
	lava.position = pos*cell_size
	$FloorGroup.add_child(lava)
	
func _generate_floor():
	#_add_floor()
	var walledTiles = []
	var lavaTiles = []
	var possiblePlayerTiles = []
	
	for tile in range(level_size.x * level_size.y):
		var tileVector = Vector2(int(floor(tile/level_size.x)), tile % int(floor(level_size.x)))
		var w = getNormalizedNoise2d(wallNoise, tileVector);
		var l = getNormalizedNoise2d(lavaNoise, tileVector);
		if (w >= 0.66):  
			walledTiles.append(tileVector)
		elif (l >= 0.88): 
			lavaTiles.append(tileVector)	
		else:
			possiblePlayerTiles.append(tileVector)			
	
			
	for wTile in walledTiles:
		_add_wall(wTile)		
	for lTile in lavaTiles:
		_add_lava(lTile)		
	for fTile in possiblePlayerTiles: 
		_add_floor(fTile)
		
	possiblePlayerTiles.shuffle()
	
	_add_player(possiblePlayerTiles[0]);
	show();
