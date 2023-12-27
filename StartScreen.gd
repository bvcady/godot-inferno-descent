extends CanvasLayer

signal start_game

func _ready():
	show()
	follow_viewport_enable = false

func _process(delta):
	if Input.is_action_pressed("ui_accept") && self.visible:
		hide()
		emit_signal("start_game")


