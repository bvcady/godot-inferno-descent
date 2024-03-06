@tool
extends StaticBody2D

enum Height {Low, Middle, High}
@export var normalPosition = Vector2(0, 0)
@export var noiseVal = 0.5
@export var displacement_vector = Vector2.ZERO
@export var crowdedness = 0
@export_color_no_alpha var colorOne: Color
@export_color_no_alpha var colorTwo: Color
@export_color_no_alpha var colorThree: Color
@export_color_no_alpha var colorFour: Color

var BASE = 32
@export var WALL_WIDTH = 28
var WALL_HEIGHT = 4
var isCornerTile = false

var image

# Called when the node enters the scene tree for the first time.
func _ready():
	noiseVal = randf()
	isCornerTile = crowdedness == 2 and displacement_vector.length() > 1
	if (randi()%12 == 0 and crowdedness == 0):
		WALL_WIDTH = 20
		
	if (isCornerTile):
		WALL_WIDTH = 20
		
	if(randi()%12 == 0):
		WALL_WIDTH += randi_range(-1, 1)*2
		
	
	WALL_HEIGHT = _defineWallHeight()
	draw_wall(WALL_WIDTH, WALL_HEIGHT, isCornerTile)
	#if isCornerTile:
		#draw_wall(12, 4)
	
func draw_wall(width: int, height: int, shouldDisplace: bool = false):
	# total occupying dimensions of the wall	
	var dim = Vector2(width, width + height)
	
	var h = height - width;
	var s = 1;
	
	# space remaining on eiher side of the wall	
	var _d = int((BASE - width)/2) 
	var d = Vector2.ONE * _d 
	
	# total amount needed to displaced and in what direction	
	var displace = Vector2i(_d * displacement_vector);
	
	if(shouldDisplace):
		displace = Vector2i(displace * 0.8)
	
	# settings for the occluder	with the size of the WALL_WIDTH (square)
	var occ = OccluderPolygon2D.new()
	var poly: PackedVector2Array = []
	poly.append(Vector2i(0, 0))
	poly.append(Vector2i(0, dim.x))
	poly.append(Vector2i(dim.x, dim.x))
	poly.append(Vector2i(dim.x, 0))
		
	occ.polygon = poly
	occ.closed = true
	
	var base = LightOccluder2D.new()
	base.occluder = occ
	base.position = d - Vector2(0, _d + 2)
	base.occluder_light_mask = 3
	add_child(base)
	
	# vertical displacement vector


	# create a new image for the wall to be drawn on. 
	var img = Image.create(dim.x, dim.y, true, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)
	
	# fill the image with a square the size of the width, barr 1 pixel either side.
	# the first param is the size of the square, the second is the start position
	_construct_top(dim.x, Vector2.ZERO, img); 
	
	# then, we add vertical walls, starting with the length, amount of subdivisions, position and whether it is mirrored.
	var v_segments = int(remap(dim.y, dim.x + 4, dim.x + 24, 2, 5))*2 + 1
	var h_segments = 5
	
	_construct_wall(dim.y - s*2, v_segments, Vector2.ZERO, true, 'VERTICAL', img);
	_construct_wall(dim.y - s*2, v_segments, Vector2(dim.x - s * 2, 0), false, 'VERTICAL', img);
	
	_construct_wall(dim.x - s*2, h_segments, Vector2(s, 0), true, 'HORIZONTAL', img);
	_construct_wall(dim.x - s*2, h_segments, Vector2(s, dim.x - s*2), false, 'HORIZONTAL', img);
	

	for i in randi_range(0, 1):
		var fade_l = randi_range(4, 10)
		_add_fade(randi_range(4, 10), randi_range(1, 3), Vector2(s + randi_range(0, dim.x - s*2 - fade_l), dim.x - s*2), img)
	
	
	var wall = TextureRect.new();
	wall.texture = ImageTexture.create_from_image(img)
	wall.position = Vector2(d.x, -height)
	if(shouldDisplace):
		wall.position += ((displacement_vector * d) - displacement_vector)
		base.position += ((displacement_vector * d) - displacement_vector)
	add_child(wall)
	
	
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
	
func _construct_top(size: int, start: Vector2, img: Image):
	var rect = Rect2(start + Vector2.ONE, Vector2.ONE * size - Vector2.ONE*2)
	img.fill_rect(rect, colorOne)
	
	
func _construct_wall(length: int, divisions: int, start: Vector2, mirrored: bool, orientation: String, img: Image): 		
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
				prefColor = colorTwo.lightened(0.2)
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
				prefColor = colorTwo.lightened(0.2)
			for x in range(_x,  _x + seg):
				img.set_pixel(x + start.x, d + start.y, prefColor)
			_x += seg
			if (d == 1):
				d = 0;
			else: 
				d = 1;
				
func _add_fade(_length: int, ammount: int, start: Vector2, img: Image):
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
	var _h = int(remap(noiseVal, 0.0, 1.0, 4.0, 24.0))
	if(isCornerTile):
		_h = clamp(_h, 4, 8)
	return _h
