extends CanvasLayer

signal start_game

func _ready():
	show();
	$StartButton.show();

func _on_StartButton_pressed():
	hide()
	emit_signal("start_game")
