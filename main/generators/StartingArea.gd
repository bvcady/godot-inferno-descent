@tool

extends CanvasLayer

var level_size = Vector2(5, 5)
const cell_size = Vector2(32,32)
var location = Vector2(0, 0);
var grid = [];
var map: Image;
var wallNoise: FastNoiseLite;

func _ready():
	hide()
	
	map = Image.new();
	map.load("res://sprites/merged-areas.png")
	wallNoise = preload("res://main/components/wall/WallsNoise.tres");
	wallNoise.seed = randi()
	
	level_size = map.get_size()
	print(level_size)

	for i in range(level_size.y):
		var row = []
		for j in range(level_size.x):
			row.append('empty')
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
		if(grid[target_cell.y][target_cell.x] != 'wall' && grid[target_cell.y][target_cell.x] != 'empty'):
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
	floor.noiseVal = getNormalizedNoise2d(wallNoise, pos)
	$FloorGroup.add_child(floor)
	
func _add_wall(pos):
	var wall = preload("res://main/components/wall/Wall.tscn").instantiate()

	var wN = getNormalizedNoise2d(wallNoise, pos)
	wall.noiseVal = wN;
	
	grid[pos.y][pos.x] = 'wall' 
	
	wall.normalPosition = pos
	wall.position = pos*cell_size
	
	print(pos, ' ', wN, ' ', wall)
	
		
	$DrawGroup.add_child(wall)
	
	_add_floor(pos)
	
func _add_player(initial_position):
	var player = $DrawGroup/PlayerCharacter
	player.hide()
	player.normalPosition = initial_position
	player.position = initial_position*cell_size 

	player.start(Vector2(level_size.x * cell_size.x,  level_size.y * cell_size.y))
	
func _generate_floor():
	#_add_floor()
	var walledTiles = []
	var possiblePlayerTiles = []
	
	for y in level_size.y:
		for x in level_size.x:
			var tileVector = Vector2(x, y)
			var p = map.get_pixelv(tileVector)
			var avgPixel = p.get_luminance()
			var alpha = p.a;
			var curPixel = avgPixel * 255;
			if (alpha == 0):
				grid[tileVector.y][tileVector.x] = 'empty'
			elif (curPixel == 0):  
				walledTiles.append(tileVector)
			elif (curPixel > 0 && curPixel < 255 && getNormalizedNoise2d(wallNoise, tileVector) > 0.5):
				walledTiles.append(tileVector)					
			else:
				grid[tileVector.y][tileVector.x] = 'floor'
				possiblePlayerTiles.append(tileVector)			
	
			
	for wTile in walledTiles:
		print(wTile)
		_add_wall(wTile)		
	for fTile in possiblePlayerTiles: 
		_add_floor(fTile)
		
	possiblePlayerTiles.shuffle()
	
	_add_player(possiblePlayerTiles[0]);
	show();
