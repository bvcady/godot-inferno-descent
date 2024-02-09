extends Node2D

var area = Vector2(200, 200);
var cell = Vector2(2, 2);
var displacement = 0.01;
var displacementNoise = FastNoiseLite.new();
var grid = [];

# Called when the node enters the scene tree for the first time.
func _ready():
	for y in area.y: 
		grid.append([])
		for x in area.x:
			grid[y].append('')
	displacementNoise.noise_type = FastNoiseLite.TYPE_PERLIN;
	displacementNoise.seed = randi();
	#displacementNoise.seed = -1488785925
	
	
	determine_area()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func determine_area():
# This would be a very nice Country shape generator
	
	for y in area.y: 
		for x in area.x:
			var tile = ColorRect.new();
			tile.position = Vector2(x, y)*cell;
			tile.size = cell;
			if (Vector2(x, y).distance_to(area/2) <= area.length()/4 + displacementNoise.get_noise_2d(x,y)/displacement): 
				tile.color=Color('white')
				grid[y][x] = 'accessible'
			else:
				tile.color=Color('black')
				grid[y][x] = 'inaccessible'
			add_child(tile)
	#print(grid)
				
	
