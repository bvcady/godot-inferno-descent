extends KinematicBody2D

export var speed = 64 # How fast the player will move (pixels/sec).
var screen_size = Vector2(400, 300)
var tilePosition = Vector2.ZERO;
var is_moving = false;

func _ready():		
	$AnimatedSprite.animation = "idle"
	$AnimatedSprite.play()
	


func _physics_process(delta):

	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		is_moving = true;		
		velocity.x = 1
	if Input.is_action_pressed("move_left"):
		is_moving = true;
		velocity.x = -1
	if Input.is_action_pressed("move_down"):
		is_moving = true;		
		velocity.y = 1
	if Input.is_action_pressed("move_up"):
		is_moving = true;		
		velocity.y = -1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed

	if velocity.x != 0:
		$AnimatedSprite.animation = "right"
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.flip_h = velocity.x < 0
	elif velocity.y != 0:
		if velocity.y < 0:
			$AnimatedSprite.animation = "up"
		elif velocity.y > 0:
			$AnimatedSprite.animation = 'down'
	elif velocity.x == 0 && velocity.y == 0:
		$AnimatedSprite.animation = 'idle'
		
	if(velocity.length() > 0):	
		move_and_slide(velocity)
		for i in get_slide_count(): 
			var collision = get_slide_collision(i)
			print(collision.position, screen_size)

	var min_wall_distance = 0;
	position.x = int(clamp(position.x, min_wall_distance, screen_size.x - min_wall_distance))
	position.y = int(clamp(position.y, min_wall_distance, screen_size.y - min_wall_distance))
	
func start(floor_size):
	if(floor_size):
		screen_size = floor_size
	else: 
		screen_size = Vector2(400, 300)
	show();

