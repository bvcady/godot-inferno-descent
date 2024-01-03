extends CanvasLayer

signal start_game

func _ready():
	show()
	follow_viewport_enabled = false

func _process(_delta):
	if Input.is_action_pressed("ui_accept") && self.visible:
		hide()
		emit_signal("start_game")
		var par = get_parent()
		par.remove_child(self)


