extends Node

signal health_changed
signal health_depleted
signal health_decreased

@export var health: int
@export var max_health: int = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	var playerScene = preload('res://main/components/player/PlayerCharacter.tscn')
	var player = playerScene.instantiate() as Player
	player.health_decreased.connect(take_damage)
	health = max_health;	
	pass # Replace with function body.

func take_damage(amount: int):
	health -= amount	
	health = max(0, health)
	if(health == 0):
		emit_signal('health_depleted') 
	print('health changed')
	emit_signal("health_changed", health)
	
func regenerate_health(amount):
	health += amount
	health = min(max_health, health);
	emit_signal("health_changed", health)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
