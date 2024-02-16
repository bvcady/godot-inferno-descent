extends Node2D
class_name Player

const cell_size = 32
var speed = 48
var move_distance = cell_size # Distance the player moves on each key press.
var screen_size 
var target_position = Vector2.ZERO
var moving = false
var current_floor
var shadow_image: Image

var narrowness = [];
var nLength = 15;
var dis = 2

@export var normalPosition = Vector2.ZERO 

signal health_decreased

func _ready():
	screen_size = get_viewport_rect().size
	show();
	current_floor = get_parent().get_parent()
	$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.play()
	target_position = position
	
	for i in nLength:
		narrowness.append(pow(dis+dis+1, 2)/1.5)
	$"Main Camera".zoom = Vector2(3,3)
	
	
	#
func _input(event):
	#if event is InputEventMouseButton && event.is_released():
		#if ($"Main Camera".zoomed == true):
			##$SpriteLight.show()
			#$"Main Camera".target_zoom = 3
			#$"Main Camera".zoomed = false
		#else:
			##$SpriteLight.hide()			
			#$"Main Camera".target_zoom = 2
			#$"Main Camera".zoomed = true
	pass
		

func _physics_process(delta):	
	var lavaMaterial = load('res://main/components/lava/Lava.tres')
	var relativePosition = position / screen_size;
	lavaMaterial.set_shader_parameter("camera_pos", relativePosition)

	handle_input()

	if moving:
		move_towards_target(delta)
		update_animation()	





func handle_input():
	if (not moving):
		var direction = Vector2.ZERO
		if Input.is_action_just_pressed("move_right"):
			direction.x = 1 
		elif Input.is_action_just_pressed("move_left"):
			direction.x = -1
		elif Input.is_action_just_pressed("move_down"):
			direction.y = 1
		elif Input.is_action_just_pressed("move_up"):
			direction.y = -1
		
		emit_signal('health_decreased')
		
		if (direction != Vector2.ZERO):
			if(current_floor && current_floor.has_method("_is_valid_move")):
				var t_tile = round(position/cell_size) + direction
				if current_floor._is_valid_move(t_tile):
					#var d = + Vector2(randf_range(-2.0, 2.0), randf_range(-3.0, 3.0));
					var t_p = t_tile * move_distance;
					target_position = round(t_p)	
					normalPosition = floor(target_position/cell_size)
					
					check_narrowness(normalPosition)
					moving = true


		
func move_towards_target(delta):
	var direction = (target_position - position).normalized()
	var move_step = speed * delta
	var distance_to_target = position.distance_to(target_position)
		
	if distance_to_target > move_step:
		position += round(4*(move_step * direction))/4
	else:
		position = target_position
		moving = false
			
	position.round()
	
func check_narrowness(_pos: Vector2):
	if current_floor.has_method("_get_narrowness"):
		var cur_narrowness = current_floor._get_narrowness(_pos, dis)
		var sq = pow(dis+dis + 1, 2)
		
		if narrowness.size() >= nLength:
			narrowness.remove_at(0)
		
		narrowness.append(cur_narrowness)
		var index = 0;
		var total = 0;
		var narrowness_value = 0;
		for history in narrowness:
			var remapped = round(remap(index, 0, nLength, 1, 4))
			index += 1
			total += remapped
			narrowness_value += history*remapped

		var t_zoom_remapped = -clamp(remap(narrowness_value, (total * sq)/4, (total * sq), -5, -2), -5, -2)
		$"Main Camera".target_zoom = t_zoom_remapped



func update_animation():
	if moving:
		var direction = (target_position - position).normalized()
		if direction.x != 0 && abs(direction.x) > abs(direction.y):
			$AnimatedSprite2D.animation = "right"
			$AnimatedSprite2D.flip_h = direction.x < 0
		else:
			if(direction.y < 0 && abs(direction.y) > abs(direction.x)):
				$AnimatedSprite2D.animation = 'up'
			else: 
				$AnimatedSprite2D.animation = "down"
	else:
		$AnimatedSprite2D.animation = 'idle'

func confine_to_screen_bounds():
	var min_wall_distance = 0
	position.x = clamp(position.x, min_wall_distance, screen_size.x - min_wall_distance)
	position.y = clamp(position.y, min_wall_distance, screen_size.y - min_wall_distance)
	if position.x <= min_wall_distance or position.x >= screen_size.x - min_wall_distance or position.y <= min_wall_distance or position.y >= screen_size.y - min_wall_distance:
		moving = false

func start(floor_size):
	if floor_size:
		screen_size = floor_size
	else:
		screen_size = Vector2(400, 300)
	show()
