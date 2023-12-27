extends Node

signal initialize_floor

func _ready():
	randomize()

func _new_game():
	emit_signal('initialize_floor')
