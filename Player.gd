extends StaticBody2D

const cell_size = 32
var speed = 48
var move_distance = cell_size # Distance the player moves on each key press.
var screen_size 
var target_position = Vector2.ZERO
var moving = false
var current_floor

func _ready():
	screen_size = get_viewport_rect().size
	show();
	current_floor = get_parent().get_parent()
	$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.play()
	target_position = position

func _physics_process(delta):	
	var lavaMaterial = load('res://Lava.tres')
	var relativePosition = position / screen_size;
	lavaMaterial.set_shader_parameter("camera_pos", relativePosition)
	
	handle_input()
	
	$"Main Camera".position = floor($"Main Camera".position)

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
		
		if (direction != Vector2.ZERO):
			if(current_floor && current_floor.has_method("_is_valid_move")):
				if current_floor._is_valid_move(round(position/cell_size) + direction):
					target_position = position + direction * move_distance
					moving = true

		
func move_towards_target(delta):
	var direction = (target_position - position).normalized()
	var move_step = speed * delta
	var distance_to_target = position.distance_to(target_position)
		
	if distance_to_target > move_step:
		position += move_step * direction
	else:
		position = target_position
		moving = false
	position.round()

func update_animation():
	if moving:
		var direction = (target_position - position).normalized()
		if direction.x != 0:
			$AnimatedSprite2D.animation = "right"
			$AnimatedSprite2D.flip_h = direction.x < 0
		else:
			if(direction.y < 0):
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
