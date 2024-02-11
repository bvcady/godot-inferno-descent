extends CanvasLayer
var GRID_WIDTH = 100;
var GRID_HEIGHT = 100;
var level_size = Vector2(GRID_WIDTH, GRID_HEIGHT)
const cell_size = Vector2(32,32)
var location = Vector2(0, 0);
var grid = [];
var map: Image = Image.new()
var wallNoise: FastNoiseLite;
var placedAreas = [];
var area_options = ['gated_area_1', 'gated_area_2', 'boulder_area_1', 'boulder_area_2', 'exit_area']
var possiblePlayerTiles = []
var pathNoise;
var displacement = 0.02;
var displacementNoise = FastNoiseLite.new();
var _scale = Vector2(10, 10);
var n_rooms = 1
var endGoal = Vector2(0, 0);


func reset(): 
	get_tree().reload_current_scene()

func _ready():
	follow_viewport_enabled = true;
	
	displacementNoise.noise_type = FastNoiseLite.TYPE_PERLIN;
	
	var totAccessible = 0;
	var minimumArea = GRID_WIDTH*GRID_HEIGHT/3

	while (totAccessible < minimumArea): 
		displacementNoise.seed = randi();
		for y in GRID_HEIGHT: 
			grid.append([])
			for x in GRID_WIDTH:
				var tile = ColorRect.new();
				if (Vector2(x, y).distance_to(Vector2(GRID_WIDTH/2, GRID_HEIGHT/2)) <= Vector2(GRID_WIDTH/2, GRID_HEIGHT/2).length()/2 + displacementNoise.get_noise_2d(x,y)/displacement): 
					totAccessible += 1
					grid[y].append({'position': Vector2(x,y), "accessible": true, "type": 'empty', "isRoom": false})
				else:
					grid[y].append({'position': Vector2(x,y), "accessible": false})
		if(totAccessible < minimumArea):
			grid = []
			totAccessible = 0;
		
	wallNoise = preload("res://main/components/wall/WallsNoise.tres");
	wallNoise.seed = randi()
	
	pathNoise = preload("res://path_noise.tres")
	pathNoise.seed = randi();
	
	
	n_rooms = int (GRID_HEIGHT * GRID_WIDTH / 500)

	for i in n_rooms: 
		_generate_floor()
	
	_draw_map();
	
	_add_tiles();

	if(possiblePlayerTiles.size()):
		var possible_steps = find_shortest_path(possiblePlayerTiles[0],endGoal, grid)
		for step in possible_steps:
			var c = ColorRect.new()
			c.position = step*  cell_size + Vector2(14, 14)
			c.size = Vector2(4, 4);
			c.color = Color.AQUA
			$StepGroup.add_child(c)
	
	print(placedAreas)
	print(placedAreas.size())
		
	

func getNormalizedNoise(noise: FastNoiseLite, x: float, y: float):
	return getNormalizedNoise2d(noise, Vector2(x, y))

func getNormalizedNoise2d(noise: FastNoiseLite, pos: Vector2):
	return (1 + noise.get_noise_2dv(pos)) / 2;
	
func get_movement_range(start: Vector2, max_distance: int):
	var directions = [Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0)]  # Right, Down, Left, Up
	var queue = [[start, 0]]  # Each element is a tuple (position, distance)
	var visited: Dictionary = {}
	visited[start] = true

	while queue.size() > 0:
		var current = queue.pop_front()  # FIFO queue
		var position = current[0]
		var distance = current[1]

		if distance < max_distance:
			for direction in directions:
				var nx = position.x + direction[0]
				var ny = position.y + direction[1]
				var next_position = Vector2(nx, ny)
				if is_valid(next_position, grid) and not visited.has(next_position):
					visited[next_position] = true
					queue.push_back([next_position, distance + 1])
	return visited

func is_valid(pos: Vector2, temp_grid):
	var x = pos.x;
	var y = pos.y;
	return x >= 0 and x < GRID_WIDTH and y >= 0 and y < GRID_HEIGHT and temp_grid[y][x].has('type') and temp_grid[y][x].type != "wall" and temp_grid[y][x]['accessible'] == true

func find_shortest_path(start: Vector2, goal: Vector2, temp_grid):
	var directions = [Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0)]  # Right, Down, Left, Up
	var queue = [start]
	var visited = {}
	visited[start] = null  # Start has no predecessor

	while queue.size() > 0:
		var current = queue.pop_front()
		if current == goal:
			var path = construct_path(visited, goal)	
			return path

		for direction in directions:
			var next_position = current + direction
			if is_valid(next_position, temp_grid) and not visited.has(next_position):
				visited[next_position] = current  # Mark current as predecessor of next_position
				queue.push_back(next_position)
	return []  # Return an empty array if no path is found
	
func construct_path(visited: Dictionary, goal: Vector2):
	var path = []
	var current = goal
	while current:
		path.insert(0, current)  # Insert at the beginning of the array
		current = visited[current]
	return path


func _is_valid_move(target_cell):
	
	var xOver0 = target_cell.x >= 0;
	var yOver0 = target_cell.y >= 0
	var xUnderWidth = target_cell.x < level_size.x;
	var yUnderHeight = target_cell.y < level_size.y;
	
	var valid_tile = xOver0 && yOver0 && xUnderWidth && yUnderHeight;

	if valid_tile:
		if(grid[target_cell.y][target_cell.x].type != 'wall' && grid[target_cell.y][target_cell.x].type != 'empty'):
			return true
	return false
	
func _add_lava(pos):
	var lava = preload("res://main/components/lava/Lava.tscn").instantiate()
	lava.position = pos*cell_size
	$FloorGroup.add_child(lava)
	
func _add_floor(pos):
	var floor = preload("res://main/components/floor/Floor.tscn").instantiate()
	floor.position = pos*cell_size
	floor.noiseVal = getNormalizedNoise2d(wallNoise, pos)
	$FloorGroup.add_child(floor)
	
func _add_wall(pos):
	var wall = preload("res://main/components/wall/Wall.tscn").instantiate()

	var wN = getNormalizedNoise2d(wallNoise, pos)
	wall.noiseVal = wN;
	
	grid[pos.y][pos.x].type = 'wall' 
	
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
			# Make sure we're not checking out of bounds or any of the tiles is 'inaccessible'
			if (x >= GRID_WIDTH or y >= GRID_HEIGHT or grid[y][x].accessible == false or grid[y][x].isRoom == true):
				canFit = false
			elif (grid[y][x].type == 'floor'): 
				hasFloor = true

	return canFit && hasFloor
	
	
func distance_from_center(a: Vector2, b: Vector2):
	var center = Vector2(GRID_WIDTH/2, GRID_HEIGHT/2)
	return center.distance_to(a) < center.distance_to(b)
	
func find_random_place(size: Vector2) -> void:
	var valid_anchors = []
	# Step 1: Identify potential anchors
	for y in GRID_HEIGHT:
		for x in GRID_WIDTH:
			if (can_fit_rectangle(x, y, size.x, size.y)):
				valid_anchors.append(Vector2(x, y))

	# Step 2: Random selection
	if valid_anchors.size() > 0:
		
		var valid_location = false;
		var attempts = 0;
		
		while (not valid_location and attempts < 3): 
			valid_anchors.shuffle()				
			var option = valid_anchors[0]
			var temp_grid = grid;
			for y in range(option.y, option.y + size.y):
				for x in range(option.x, option.x + size.x):
					var tileVector = Vector2(x, y)
					var p = map.get_pixelv(tileVector - option)
					var avgPixel = p.get_luminance()
					var alpha = p.a;
					var curPixel = avgPixel * 255;

					if (curPixel == 0):
						temp_grid[tileVector.y][tileVector.x].type = 'wall';
					elif (curPixel > 0 && curPixel < 255 && getNormalizedNoise2d(wallNoise, tileVector) > 0.5):
						temp_grid[tileVector.y][tileVector.x].type = 'wall';
					else:
						if placedAreas.size() == 1:
							possiblePlayerTiles.append(tileVector)
						temp_grid[tileVector.y][tileVector.x].type = 'floor'
					temp_grid[tileVector.y][tileVector.x].isRoom = true;
					
			if placedAreas.size() == 1: 		
				valid_location = true
				
			else: 	
				var pathToOptions = find_shortest_path(possiblePlayerTiles[0], option, temp_grid)
				valid_location = pathToOptions.size() > 0;
				attempts += 1;
				if(attempts == 3 and not valid_location):
					'Skipping attempt to place room'
				
			if(valid_location):
				endGoal = option
				location = option
				grid = temp_grid
				placedAreas.append({"position": valid_anchors[0], "area": size})


func _generate_floor():
	area_options.shuffle()
	var walledTiles = []
	if(placedAreas.size() == 0):
		var s = level_size
		var location = Vector2(0, 0);
		for y in range(s.y):
			for x in range(s.x):
				var tileVector = Vector2(x, y)
				if grid[y][x].accessible == true:
					if (getNormalizedNoise2d(pathNoise, tileVector) > 0.85):
						grid[tileVector.y][tileVector.x].type = 'floor'
					elif(getNormalizedNoise2d(pathNoise, tileVector) > 0.4):
						grid[tileVector.y][tileVector.x].type = 'wall'	
					else: 
						grid[tileVector.y][tileVector.x].type = 'empty';
		placedAreas.append({"position": Vector2(location.x + s.x, location.y + s.y), "area": s})	
	else: 
		if(placedAreas.size() == 1):
			map.load("res://sprites/start_area.png")
		else:			
			var chosen = area_options[0]	
			map.load("res://sprites/" + chosen + '.png')	
		var mapSize = map.get_size();
		var validLocation = false
		var location = Vector2(-1, -1)
		var attempts = 0;
		find_random_place(mapSize)

func _draw_map ():
	var img = Image.create(GRID_WIDTH * _scale.x, GRID_HEIGHT * _scale.y, true, Image.FORMAT_RGBA8);
	
	for row in grid:
		for item in row: 
			if (item.has('accessible') and item.accessible == false):
				for p_x in range(item.position.x * _scale.x, item.position.x * _scale.x + _scale.x):
					for p_y in range(item.position.y * _scale.y, item.position.y * _scale.y + _scale.y):
						img.set_pixel(p_x, p_y, Color.TRANSPARENT);				
			elif (item.has('type') and item.has('position') and item.type == 'floor'):
				for p_x in range(item.position.x * _scale.x, item.position.x * _scale.x + _scale.x):
					for p_y in range(item.position.y * _scale.y, item.position.y * _scale.y + _scale.y):
						img.set_pixel(p_x, p_y, Color.WHEAT);				
			elif(item.has('type') and item.type == 'wall'):
				for p_x in range(item.position.x * _scale.x, item.position.x * _scale.x + _scale.x):
					for p_y in range(item.position.y * _scale.y, item.position.y * _scale.y + _scale.y):
						img.set_pixel(p_x, p_y, Color.BLACK);				

	var floorMapTexture = ImageTexture.create_from_image(img)
	$UI/FloorMap.hide();
	$UI/FloorMap.texture = floorMapTexture;
	$UI/FloorMap.position = Vector2(10, 10)
	$UI/FloorMap.scale = Vector2(0.2, 0.2)
	
	
func _add_tiles ():
	for row in grid:
		for item in row: 
			if (item.has('accessible') and item.accessible == false):
				continue;
			elif (item.has('type') and item.has('position') and item.type == 'floor'):
				_add_floor(item.position)
				#new_floor.position = Vector2(item.position.x * cell_size.x, item.position.y * cell_size.y)
			elif(item.has('type') and item.type == 'wall'):
				var new_wall = preload("res://main/components/wall/Wall.tscn");
				_add_wall(item.position)
				
	possiblePlayerTiles.shuffle();
	if(possiblePlayerTiles.size()):
		_add_player(possiblePlayerTiles[0])
		_add_lava(possiblePlayerTiles[1])
	
	
