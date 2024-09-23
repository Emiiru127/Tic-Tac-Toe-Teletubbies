extends CanvasLayer


func _ready():
	if GlobalData.starting_player == -1 :
		$CheckBox.button_pressed = true
	else :
		$CheckBox.button_pressed = false
	

func _on_play_against_ai_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")
	GlobalData.againstAI = true


func _on_play_against_player_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")


func set_player(toggled_on: bool) -> void:
	if toggled_on :
		GlobalData.set_player(-1)
	else :
		GlobalData.set_player(1)

func _on_check_box_toggled(toggled_on: bool) -> void:
	set_player(toggled_on)


func _on_game_history_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game_history.tscn")
