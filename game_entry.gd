extends MarginContainer

@export var game_move_scene : PackedScene

func _ready() -> void:
	pass
	
func set_data(match_id : String, match_type : String, player_on_second : bool, match_result : String, match_moves : Array):
		
	$HBoxContainer/VBoxContainer/game_id.text = "Game ID: " + match_id
	$HBoxContainer/VBoxContainer/match_type.text = "Game Type: " + match_type
	
	if match_result == "DRAW":
		$HBoxContainer/VBoxContainer/match_result.text = "Result: " + match_result + "!"	
	else:
		$HBoxContainer/VBoxContainer/match_result.text = "Result: " + match_result + " Wins!"	
	
	$HBoxContainer/MarginContainer/VBoxContainer2/match_moves.text = "Moves: " + str(match_moves.size())

	var moves : Array = [
		["   ", "   ", "   "],
		["   ", "   ", "   "],
		["   ", "   ", "   "]
	]
	
	var on_second : bool = player_on_second
	var num_of_move : int = 1
	var temp : bool = false
	
	var againstAI : bool = true if match_type == "Player vs AI" else false
	var player : String
	var player_tag : String
	
		
	if againstAI == true:
		if on_second == true:
			player = "AI"
		else :
			player = "Player"
	else:
		player = "Player 1"

	for move in match_moves:
		var splitted1 = -1
		var splitted2 = -1
		
		for i in move.split(","):
			if splitted1 == -1: 
				splitted1 = int(i)
			else  : 
				splitted2 = int(i)
			
		
		if temp == false:
			moves[int(splitted2)][int(splitted1)] = "O"
			player_tag = " (O)"
			temp = true
		else :
			moves[int(splitted2)][int(splitted1)] = "X"
			player_tag = " (X)"
			temp = false
	
		var game_move = game_move_scene.instantiate()
		game_move.set_data(moves, player + player_tag, num_of_move, str(splitted1) + "," + str(splitted2))
		
		if againstAI == true:
			if player == "Player":
				player = "AI"
			else :
				player = "Player"
		else:
			if player == "Player 1":
				player = "Player 2"
			else :
				player = "Player 1"
		
		num_of_move += 1
		
		$HBoxContainer/MarginContainer/VBoxContainer2/moves_container.add_child(game_move)
			
