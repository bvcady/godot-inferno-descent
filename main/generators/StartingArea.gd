extends CanvasLayer
var GRID_WIDTH = 80;
var GRID_HEIGHT = 80;
var level_size = Vector2(GRID_WIDTH, GRID_HEIGHT)
const cell_size = Vector2(32,32)
var location = Vector2(0, 0);
var grid = [];
var map: Image = Image.new()
var wallNoise: FastNoiseLite;
var placedAreas = [];
var area_options = ['gated_area_1', 'gated_area_2', 'boulder_area_1', 'boulder_area_2', 'exit_area', 'random']
var possiblePlayerTiles = []
var pathNoise;

func _ready():
	hide()
	follow_viewport_enabled = true;
	
	for y in level_size.y:
		var row = []
		for x in level_size.x:
			row.append('empty')
		grid.append(row)
		
	wallNoise = preload("res://main/components/wall/WallsNoise.tres");
	wallNoise.seed = randi()
	
	pathNoise = preload("res://path_noise.tres")
	pathNoise.seed = randi();
	
	for i in 1: 
		_generate_floor()
	show()
	
func getNormalizedNoise(noise: FastNoiseLite, x: float, y: float):
	return getNormalizedNoise2d(noise, Vector2(x, y))

func getNormalizedNoise2d(noise: FastNoiseLite, pos: Vector2):
	return (1 + noise.get_noise_2dv(pos)) / 2;

func _is_valid_move(target_cell):
	
	var xOver0 = target_cell.x >= 0;
	var yOver0 = target_cell.y >= 0
	var xUnderWidth = target_cell.x < level_size.x;
	var yUnderHeight = target_cell.y < level_size.y;
	
	var valid_tile = xOver0 && yOver0 && xUnderWidth && yUnderHeight;

	if valid_tile:
		if(grid[target_cell.y][target_cell.x] != 'wall' && grid[target_cell.y][target_cell.x] != 'empty'):
			return true
	return false
	
	
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
	
	$DrawGroup.add_child(wall)
	
	_add_floor(pos)
	
func _add_player(initial_position):
	var player = $DrawGroup/PlayerCharacter
	
	player.hide()
	player.normalPosition = initial_position
	player.position = initial_position*cell_size 

	player.start(Vector2(level_size.x * cell_size.x,  level_size.y * cell_size.y))


#func has_neighbouring_wall(x, y):
	 ## Check each neighbour (up, down, left, right)
	#for offset in [Vector2(0, -1), Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0)]:
		#var neighbour_x = x + offset.x
		#var neighbour_y = y + offset.y
#
		## Make sure we're not checking out of bounds
		#if neighbour_x >= 0 and neighbour_x < GRID_WIDTH and neighbour_y >= 0 and neighbour_y < GRID_HEIGHT:
			#if grid[neighbour_x][neighbour_y] == 'floor':
				#return true
#
	#return false


func can_fit_rectangle(s_x, s_y, a, b):
	var hasFloor = false;
	var canFit = true;
	
	var area = []
	# Check each cell within the a x b area
	for x in range(s_x, s_x + a):
		for y in range(s_y, s_y + b):
			# Make sure we're not checking out of bounds	
			if x >= GRID_WIDTH or y >= GRID_HEIGHT or grid[y][x] == 'wall':
				canFit = false
			elif (grid[y][x] == 'floor'): 
				hasFloor = true

	return canFit && hasFloor
	
	
func distance_from_center(a: Vector2, b: Vector2):
	var center = Vector2(GRID_WIDTH/2, GRID_HEIGHT/2)
	return center.distance_to(a) < center.distance_to(b)
	
func find_random_place(a, b):
	var valid_anchors = []

	if (placedAreas.size() == 0):
		valid_anchors.append(Vector2(floor(GRID_WIDTH/2), floor(GRID_HEIGHT/2)))
	else:
		# Step 1: Identify potential anchors
		for y in GRID_HEIGHT:
			for x in GRID_WIDTH:
				if ((grid[y][x] == 'empty' or grid[y][x] == 'floor') and can_fit_rectangle(x, y, a, b)):
					valid_anchors.append(Vector2(x, y))
	


	# Step 3: Random selection
	if valid_anchors.size() > 0:
		
		valid_anchors.sort_custom(distance_from_center)
		var sliced_valid_anchors = valid_anchors.slice(0, 10)
		sliced_valid_anchors.shuffle();
		var selected_anchor = sliced_valid_anchors[0]
	
		#print((selected_anchor - Vector2(a, b)/2).distance_to(Vector2(GRID_WIDTH/2, GRID_HEIGHT/2)))
		#
		#print('found ', selected_anchor)
		#print('area ', selected_anchor + Vector2(a, b))
		placedAreas.append({"position": selected_anchor, "area": Vector2(a, b)})
		
		# Step 4: Place the rectangles
		return selected_anchor
		
	print('no valid location found')
	return Vector2(-1, -1)  # No valid position found


func _generate_floor():
	area_options.shuffle()
	
	var walledTiles = []
	

		
	if(placedAreas.size() == 0 || area_options[0] == 'random'):
		var s = GRID_WIDTH/2 - 1;
		var location = find_random_place(s, s)
		for y in range(s):
			for x in range(s):
				var tileVector = Vector2(location.x + x, location.y + y)
				if (getNormalizedNoise2d(pathNoise, tileVector) > 0.8):
					grid[tileVector.y][tileVector.x] = 'floor'
					possiblePlayerTiles.append(tileVector)		
				elif(getNormalizedNoise2d(pathNoise, tileVector) > 0.6):
					grid[tileVector.y][tileVector.x] = 'wall'	
					walledTiles.append(tileVector)					
				else:
					grid[tileVector.y][tileVector.x] = 'empty'
					
		#placedAreas.append({"position": selected_anchor, "area": Vector2(a, b)})
		placedAreas.append({"position": Vector2(location.x + s, location.y + s), "area": Vector2(s, s)})	
	else: 
		if(placedAreas.size() == 1):
			map.load("res://sprites/start_area.png")
		else:
			var chosen = area_options[0]	
			map.load("res://sprites/" + chosen + '.png')	
		var mapSize = map.get_size();
		var location = find_random_place(mapSize.x, mapSize.y)		
		if (location.x == -1 or location.y == -1):
			return
		
		var area = Vector2(mapSize.x + location.x, mapSize.y + location.y)

		for y in range(location.y, area.y):
			for x in range(location.x, area.x):
				var tileVector = Vector2(x, y)
				var p = map.get_pixelv(tileVector - location)
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
		_add_wall(wTile)		
	for fTile in possiblePlayerTiles: 
		_add_floor(fTile)
	possiblePlayerTiles.shuffle()
	_add_player(possiblePlayerTiles[0])
	return
	

