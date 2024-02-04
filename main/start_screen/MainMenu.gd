extends Control

signal start_game

func _ready():
	$MarginContainer/HomeMenu/NewGameButton.grab_focus();

func _on_new_game_pressed ():
	get_tree().change_scene_to_file('res://main/generators/StartingArea.tscn')
	
func _on_load_game_pressed ():
	pass;
	
func _on_quit_game_pressed ():
	get_tree().quit();
