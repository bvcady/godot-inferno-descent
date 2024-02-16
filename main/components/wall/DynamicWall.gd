extends StaticBody2D

enum Height {Low, Middle, High}
@export var normalPosition = Vector2(0, 0)
@export var noiseVal = 0.0
@export var displacement_vector = Vector2.ZERO
@export var crowdedness = 0
@export_color_no_alpha var colorOne
@export_color_no_alpha var colorTwo
@export_color_no_alpha var colorThree
@export_color_no_alpha var colorFour

@export var WALL_WIDTH = 30


var img: Image
var image
var h 

# Called when the node enters the scene tree for the first time.
func _ready():
	WALL_WIDTH = remap(crowdedness, 0, 25, 20, 32)
	
	var occ = OccluderPolygon2D.new()
	var poly: PackedVector2Array = []
	var d = Vector2(32 - WALL_WIDTH, 32 - WALL_WIDTH)/2;
	
	var displace = Vector2i(d.x * displacement_vector);
	
	var yD = Vector2(0, 32 - WALL_WIDTH)/2
	poly.append(Vector2(0, 0) + d - yD)
	poly.append(Vector2(0, WALL_WIDTH) + d - yD)
	poly.append(Vector2(WALL_WIDTH, WALL_WIDTH) + d - yD)
	poly.append(Vector2(WALL_WIDTH, 0) + d - yD)
	
	occ.polygon = poly
	occ.closed = true
	
	$Base.occluder = occ
	position += Vector2(displace)
	
	img = Image.create(32, 64, true, Image.FORMAT_RGBA8)
	
	_defineWallHeight()
		
	for x in img.get_width():
		for y in img.get_height():
			img.set_pixel(x, y, Color.TRANSPARENT)
	

	var s = 1;
	
	_construct_top(WALL_WIDTH - s*2, Vector2(s, WALL_WIDTH - h + s));

	_construct_wall(h + WALL_WIDTH - s*2, 10, Vector2(0, WALL_WIDTH - h + s), true, 'VERTICAL');
	_construct_wall(h + WALL_WIDTH - s*2, 10, Vector2(WALL_WIDTH - s*2, WALL_WIDTH - h + s), false, 'VERTICAL');
	
	_construct_wall(WALL_WIDTH - s*2, 5, Vector2(s, WALL_WIDTH - h), true, 'HORIZONTAL');
	_construct_wall(WALL_WIDTH - s*2, 5, Vector2(s, WALL_WIDTH*2 - h - s*2), false, 'HORIZONTAL');
	

	for i in randi_range(0, 2):
		_add_fade(randi_range(4, 10), randi_range(1, 3), Vector2(s + randi_range(3, WALL_WIDTH - 10), WALL_WIDTH*2 - h - s*2))
	
	
	var wall = TextureRect.new();
	wall.texture = ImageTexture.create_from_image(img)
	wall.position = Vector2((32 - WALL_WIDTH)/2, - WALL_WIDTH);
	add_child(wall)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func generate_divisions(l: int, d: int) -> Array:
	
	assert (d > 0 and l >= d, "The number of divisions must be positive and less than or equal to the length.") 
	var points = []  # Start with 0 as the first partition point

	var remainder = l;
	var added = 0;
	# Generate d-1 random partition points
	
	for i in range(d - 1):
		var limit = clamp(remainder, 2, (l/d) * 3);
		var point = randi_range(2, limit)
		if point >= remainder:
			point = remainder
		remainder -= point
		added += point
		points.append(point)
		if remainder == 0: 
			break
	if remainder > 0:
		points.append(remainder)

	return points
	
func _construct_top(size: int, start: Vector2):
	for x in size:
		for y in size: 
			img.set_pixel(x + start.x, y + start.y, colorOne)
	
	
func _construct_wall(length: int, divisions: int, start: Vector2, mirrored: bool, orientation: String): 		
	var wall_segments = generate_divisions(length, divisions)
	
	var _y = 0;
	var _x = 0;
	var d = 0;
	
	if(mirrored): 
		d = 0
	else: 
		d = 1;
	
	if orientation == 'VERTICAL':
		for seg in wall_segments:
			var prefColor = colorTwo;
			if d == 1 and randi() % 5 == 1: 
				prefColor = colorThree
			for y in range(_y,  _y + seg):
				img.set_pixel(d + start.x, y + start.y, prefColor)
			_y += seg
			if (d == 1):
				d = 0;
			else: 
				d = 1;
	else: 
		for seg in wall_segments:
			var prefColor = colorTwo;
			if d == 1 and randi() % 10 == 1: 
				prefColor = colorThree
			for x in range(_x,  _x + seg):
				img.set_pixel(x + start.x, d + start.y, prefColor)
			_x += seg
			if (d == 1):
				d = 0;
			else: 
				d = 1;
				
func _add_fade(_length: int, ammount: int, start: Vector2):
	var iteration = 0;
	var length = _length;

	var startPixel = img.get_pixelv(start);
	var deltaY = 0
	if (startPixel.r == 0):
		deltaY = -1;

	img.set_pixel(start.x - 1, start.y + deltaY, colorTwo);
	img.set_pixel(start.x + length + 1, start.y + deltaY, colorTwo);
		
	while length > 0 and iteration <= ammount:
		for i in length:
			var prefColor = colorOne
			if (i % 2 == 1): 
				prefColor = colorFour
			img.set_pixel(start.x + i + iteration, start.y + iteration + deltaY, prefColor);
		length -= 2;
		iteration += 1;	
	

func _defineWallHeight():
	h = int(remap(noiseVal, 0, 1, 4, 24))
