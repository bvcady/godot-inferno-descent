extends CanvasLayer
var GRID_WIDTH = 40;
var GRID_HEIGHT = 40;
var level_size = Vector2(GRID_WIDTH, GRID_HEIGHT)
const cell_size = Vector2(32,32)
var location = Vector2(0, 0);
var grid = [];
var wallNoise: FastNoiseLite;
var placedAreas = [];
var area_options = ['gated_area_1', 'gated_area_2', 'boulder_area_1', 'boulder_area_2', 'exit_area', 'boss_area']
var possiblePlayerTiles = []
var pathNoise;
var displacement = 0.02;
var displacementNoise = FastNoiseLite.new();
var _scale = Vector2(10, 10);
var n_rooms = 1
var endGoal = Vector2(0, 0);
var max_attempts = 10

@export var floorColor = Color.BLACK;
var wallColor = floorColor;
@export var edgeColor = Color.BLACK;

#var floorColor = Color.from_string('#524c52', Color.BURLYWOOD)
#var wallColor = Color(floorColor.darkened(0.1))

var dirs = [Vector2(0, -1), Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0)]

func reset(): 
	get_tree().reload_current_scene()

func largest_of(a: int, b: int):
	if a >= b: 
		return a
	else:
		return b

func _ready():	
	wallColor = floorColor.darkened(0.1);
	var from = Time.get_ticks_msec();
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
					grid[y].append({'position': Vector2(x,y), "accessible": true, "isRoom": false, "type": "empty"})
				else:
					grid[y].append({'position': Vector2(x,y), "accessible": false, "isRoom": false, "type": "empty"})
		if(totAccessible < minimumArea):
			grid = []
			totAccessible = 0;
		
	wallNoise = preload("res://main/components/wall/WallsNoise.tres");
	wallNoise.seed = randi()
	
	pathNoise = preload("res://path_noise.tres")
	pathNoise.seed = randi();
	
	
	#n_rooms = int(GRID_WIDTH*GRID_HEIGHT / 500) 
	n_rooms = int(largest_of(GRID_WIDTH, GRID_HEIGHT)/10) + 1
	print('Attempting to place ', n_rooms - 1, ' rooms.')
	if n_rooms <= 1: 
		n_rooms = 2
	
	var start = Time.get_ticks_msec()
	for i in n_rooms: 
		_generate_floor()

	var end = Time.get_ticks_msec()
	print('Procedurally place rooms, ', (end - start), ' ms.')
	
	for y in GRID_HEIGHT:
		for x in GRID_WIDTH:
			var tile = grid[y][x];
			if (tile.has('type') == false or (tile.has('type') and tile.type == 'empty')) and neighbours_floor(x,y):
				tile.accessible = true
				tile.type = 'wall'
	
	_determine_wall_position()
			
	_draw_map();
	
	_add_tiles();
	
	draw_floor();

	var to = Time.get_ticks_msec();
	print('Succeeded placing ', placedAreas.size() - 1, ' rooms.')
	print('Total elapsed time generating level ', (to - from)/1000.0, ' seconds.')
	#if(possiblePlayerTiles.size()):
		#var possible_steps = find_shortest_path(possiblePlayerTiles[0],endGoal, grid)
		#for step in possible_steps:
			#var c = ColorRect.new()
			#c.position = step*  cell_size + Vector2(14, 14)
			#c.size = Vector2(4, 4);
			#c.color = Color.AQUA
			#$StepGroup.add_child(c)
	
		
func _get_narrowness(pos: Vector2, dis: int): 
	var directions = []  # Right, Down, Left, Up
	for x in range(-dis, dis + 1):
		for y in range(-dis, dis + 1):
			directions.append(Vector2(x, y))
			
	var n = 0;
	for dir in directions:
		var neighbour = pos + dir
		if (neighbour.x < GRID_WIDTH and neighbour.y < GRID_HEIGHT and neighbour.x >= 0 and neighbour.y >=0):
			if (grid[neighbour.y][neighbour.x].has('type') and grid[neighbour.y][neighbour.x].type == 'floor'):
				n += 1
	return n

func getNormalizedNoise(noise: FastNoiseLite, x: float, y: float):
	return getNormalizedNoise2d(noise, Vector2(x, y))

func getNormalizedNoise2d(noise: FastNoiseLite, pos: Vector2):
	return (1 + noise.get_noise_2dv(pos)) / 2;
	
func get_movement_range(start: Vector2, max_distance: int):
	var queue = [[start, 0]]  # Each element is a tuple (position, distance)
	var visited: Dictionary = {}
	visited[start] = true

	while queue.size() > 0:
		var current = queue.pop_front()  # FIFO queue
		var position = current[0]
		var distance = current[1]

		if distance < max_distance:
			for dir in dirs:
				var next_position = position + dir
				if is_valid(next_position, grid) and not visited.has(next_position):
					visited[next_position] = true
					queue.push_back([next_position, distance + 1])
	return visited

func is_valid(pos: Vector2, temp_grid):
	var x = pos.x;
	var y = pos.y;
	return x >= 0 and x < GRID_WIDTH and y >= 0 and y < GRID_HEIGHT and temp_grid[y][x].has('type') and temp_grid[y][x].type != "wall" and temp_grid[y][x]['accessible'] == true

func find_shortest_path(start: Vector2, goal: Vector2, temp_grid):
	var queue = [start]
	var visited = {}
	visited[start] = null  # Start has no predecessor

	while queue.size() > 0:
		var current = queue.pop_front()
		if current == goal:
			var path = construct_path(visited, goal)	
			return path

		for dir in dirs:
			var next_position = current + dir
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
		if(grid[target_cell.y][target_cell.x].has('type') and grid[target_cell.y][target_cell.x].type != 'wall' && grid[target_cell.y][target_cell.x].type != 'empty'):
			return true
	return false
	
func _add_lava(pos):
	var lava = preload("res://main/components/lava/Lava.tscn").instantiate()
	lava.position = pos*cell_size
	$FloorGroup.add_child(lava)
	
#func _add_floor(pos, _color: Color = Color.TRANSPARENT):
	#var floor = preload("res://main/components/floor/Floor.tscn").instantiate()
	#floor.position = pos*cell_size
	#floor.color = _color
	#floor.noiseVal = getNormalizedNoise2d(wallNoise, pos)
	#$FloorGroup.add_child(floor)
	
func _add_wall(pos):
	var wall = preload("res://main/components/wall/DynamicWall.tscn").instantiate()

	var wN = getNormalizedNoise2d(wallNoise, pos)
	wall.noiseVal = wN;
	var tile = grid[pos.y][pos.x]
	if (tile.has('wall_displacement')):
		wall.displacement_vector = tile.wall_displacement
	if (tile.has('crowdedness')):
		wall.crowdedness = tile.crowdedness
	wall.normalPosition = pos
	wall.position = pos*cell_size
	
	
	$DrawGroup.add_child(wall)
	
	
func _add_player(initial_position):
	var player = $DrawGroup/PlayerCharacter
	
	player.hide()
	player.normalPosition = initial_position
	player.position = initial_position*cell_size 

	player.start(Vector2(level_size.x * cell_size.x,  level_size.y * cell_size.y))


func can_fit_rectangle(_x, _y, size: Vector2):
	var hasFloor = false;
	var canFit = true;
	
	var area = []
	# Check each cell within the a x b area
	if _x + size.x >= GRID_WIDTH: 
		return false
	if _y + size.y >= GRID_HEIGHT: 
		return false
		
	for x in range(_x, _x + size.x):
		for y in range(_y, _y + size.y):
			if (grid[y][x].accessible == false or grid[y][x].isRoom == true):
				canFit = false
			elif (grid[y][x].type == 'floor'): 
				hasFloor = true

	return hasFloor and canFit
	
	
func distance_from_center(a: Vector2, b: Vector2):
	var center = Vector2(GRID_WIDTH/2, GRID_HEIGHT/2)
	return center.distance_to(a) < center.distance_to(b)
	
func find_random_place(room: Image) -> void:	
	var size = room.get_size();
	var valid_anchors = []
	
	# Step 1: Identify potential anchors
	
	if placedAreas.size() == 1:
		valid_anchors.append(Vector2(GRID_WIDTH/2 - size.x/2, GRID_HEIGHT/2 - size.y/2))
	else: 
		for y in range(0, GRID_HEIGHT - size.y - 2):
			for x in range(0, GRID_WIDTH - size.x - 2):
				if (can_fit_rectangle(x, y, size)):
					valid_anchors.append(Vector2(x, y))

	# Step 2: Random selection
	if valid_anchors.size() > 0:
		
		var valid_location = false;
		var attempts = 0;
		
		var option = valid_anchors[0]
		
		var temp_grid = [];
		
		while (not valid_location and attempts < max_attempts): 
			valid_anchors.shuffle()	
			option = valid_anchors[0]			
			temp_grid = grid.duplicate(true);

			for y in size.y:
				for x in size.x:
					var tileVector = Vector2(x + option.x, y + option.y)
					var p = room.get_pixelv(tileVector - option)

					var avgPixel = p.get_luminance()
					var alpha = p.a;
					var curPixel = avgPixel * 255;
					if not (alpha == 0):
						if (curPixel == 0):
							temp_grid[tileVector.y][tileVector.x].type = 'wall';
						else:
							if curPixel < 255: 
								endGoal = tileVector
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
				if(attempts == max_attempts and not valid_location):
					'skip'
					#print('Skipping attempt to place room')
				
		if(valid_location):
			endGoal = option
			location = option
			grid = temp_grid.duplicate(true)
			placedAreas.append({"position": valid_anchors[0], "area": size})


func _generate_floor():
	area_options.shuffle()
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
		var room: Image = Image.new()
		if(placedAreas.size() == 1):
			room.load("res://sprites/start_area.png")
		else:			
			var chosen = area_options[0]	
			room.load("res://sprites/" + chosen + '.png')	
			for i in randi() % 4: 
				room.rotate_90(CLOCKWISE)		
		find_random_place(room)
		


func neighbours_floor(x,y):
	var surrounding_dirs = [Vector2(0, 1), Vector2(0, -1), Vector2(-1, 0), Vector2(1, 0), Vector2(1, 1), Vector2(-1, 1), Vector2(1, -1), Vector2(-1, -1)]
				
	var valid = false
	for dir in surrounding_dirs:
		if not (y + dir.y >= GRID_HEIGHT or x + dir.x >= GRID_WIDTH or y + dir.y < 0 or x + dir.x < 0):
			var tile = grid[y + dir.y][x + dir.x];
			if (tile.has('type') and tile.type == 'floor'):
				valid = true
	return valid
				

func _draw_map ():
	var start = Time.get_ticks_msec()
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
						img.set_pixel(p_x, p_y, floorColor);				
			elif(item.has('type') and item.type == 'wall'):
				for p_x in range(item.position.x * _scale.x, item.position.x * _scale.x + _scale.x):
					for p_y in range(item.position.y * _scale.y, item.position.y * _scale.y + _scale.y):
						img.set_pixel(p_x, p_y, floorColor.darkened(0.4));				

	var floorMapTexture = ImageTexture.create_from_image(img)
	$UI/FloorMap.hide();
	$UI/FloorMap.texture = floorMapTexture;
	$UI/FloorMap.position = Vector2(0, 0)
	var _scale = (get_window().size.y / floorMapTexture.get_size().y);
	$UI/FloorMap.scale = Vector2(_scale, _scale)
	
	var end = Time.get_ticks_msec()
	print('Drawing in-game map, ', (end - start), ' ms.')
	

func _determine_wall_position ():
	var start = Time.get_ticks_msec()
	for x in GRID_WIDTH:
		for y in GRID_HEIGHT: 
			var tile = grid[y][x]
			if tile.has("type") and tile.type == 'wall':
				var dir = Vector2.ZERO;
				var nWalls = 0
				for ndir in dirs:
					var vec = Vector2(x,y) + ndir;
					if (vec.x >= 0 and vec.x < GRID_WIDTH and vec.y >= 0 and vec.y < GRID_HEIGHT):
							var neighbouring_tile = grid[vec.y][vec.x]
							if neighbouring_tile.has('type') and neighbouring_tile.type == 'wall':
								dir += ndir
								nWalls += 1
					else: 
							dir += ndir
							nWalls += 1
				#for i in range(-2, 3):
					#for j in range(-2, 3):
						#if (i + x >= 0 and i + x < GRID_WIDTH and j + y >= 0 and j + y < GRID_HEIGHT):
							#var neighbouring_tile = grid[y + j][x + i]
							#if neighbouring_tile.has('type') and neighbouring_tile.type == 'wall':
								#dir += Vector2(i, j)
								#nWalls += 1
						#else: 
							#dir += Vector2(i, j)
							#nWalls += 1
				grid[y][x].wall_displacement = dir
				grid[y][x].crowdedness = nWalls
			
	var end = Time.get_ticks_msec()
	print('Displacing wall positions, ', (end - start), ' ms.')
	
	
				
func draw_floor ():
	
	var start = Time.get_ticks_msec()
	
	var floorImage = Image.create(GRID_WIDTH*cell_size.x, GRID_HEIGHT*cell_size.y, true, Image.FORMAT_RGBA8)
	
	for x in GRID_WIDTH:
		for y in GRID_HEIGHT:
			var actualCell = grid[y][x]
			var rect = Rect2i(x*32,y*32, 32, 32)
			if actualCell.has('accessible') and actualCell.accessible == true:	
				if actualCell.has('type') and actualCell.type == 'wall':
					floorImage.fill_rect(rect, wallColor)
				else:
					floorImage.fill_rect(rect, floorColor)

	
	
	var ratio = 4;
	var inv = 32/ratio;
	
	var s_grid = []
	for y in GRID_HEIGHT * ratio:
		s_grid.append([])
		for x in GRID_WIDTH * ratio:
			s_grid[y].append('')
	
	for x in GRID_WIDTH * ratio:
		for y in GRID_HEIGHT * ratio:
			s_grid[y][x] = grid[y/ratio][x/ratio].type
					
	for x in GRID_WIDTH * ratio:
		for y in GRID_HEIGHT * ratio:
			var current_cell = s_grid[y][x]
			if(current_cell) != 'floor':
				continue
			var rect = Rect2i(x*inv,y*inv, inv, inv)
			var f = floorImage.get_pixel(x*inv, y*inv)
			for dir in dirs:
				var pos = Vector2(x + dir.x, y + dir.y)
				var within_bounds = pos.x >= 0 and pos.x < GRID_WIDTH*ratio and pos.y >= 0 and pos.y < GRID_HEIGHT*ratio
				if within_bounds:
					var next_to_wall = s_grid[pos.y][pos.x] == 'wall'					
					var r = randi()%6 == 0
					if next_to_wall and r:
						floorImage.fill_rect(rect, wallColor)

	
	var floorTexture = ImageTexture.create_from_image(floorImage)
	
	$FloorGroup/FloorRect.texture = floorTexture
	
	var end = Time.get_ticks_msec()
	print('Drawing floor picture, ', (end - start), ' ms.')
	
func _add_tiles ():
	var start = Time.get_ticks_msec();
	for row in grid:
		for item in row: 
			if (item.has('accessible') and item.accessible == false):
				continue;
			elif(item.has('type') and item.type == 'wall'):
				_add_wall(item.position)
			elif(randi()%80 == 0):
				var smoke = preload('res://main/components/smoke/Smoke.tscn').instantiate()
				var lava = preload("res://main/components/lava/Lava.tscn").instantiate()
				#print('placing smoke')
				smoke.position = item.position * 32 - Vector2(0, -4)
				$DrawGroup.add_child(smoke)
				lava.position = item.position * 32
				$FloorGroup.add_child(lava)
				
	possiblePlayerTiles.shuffle();
	if(possiblePlayerTiles.size()):
		_add_player(possiblePlayerTiles[0])
		#_add_lava(possiblePlayerTiles[1])
	
	
	var end = Time.get_ticks_msec();
	print('Adding all tiles, ', (end - start), ' ms.')
	
	
	

	
