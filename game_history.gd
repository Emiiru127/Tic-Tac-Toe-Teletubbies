extends Control

@export var game_entry_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	# Fetch game history from the database
	var result = GlobalData.database.select_rows("gameHistoryTable", "game_id > 0", ["*"])

	# Iterate through the result and add each game history to the UI
	for row in result:
		add_game_history(row)

# Add a game's history (game ID, match type, result, and the move grid) to the UI
func add_game_history(row):
	# Create a VBoxContainer for each game entry

	var match_id : String = str(row["game_id"])
	var match_type : String = row["match_type"]
	var player_on_second : bool = row["player_on_second"]
	var match_result : String = row["result"]
	var match_moves : Array = row["moves"].split(":")
	
	print(match_id)
	print(match_type)
	print(player_on_second)
	print(match_result)
	print(match_moves)
	print()
	
	var game_entry = game_entry_scene.instantiate()
	game_entry.set_data(match_id, match_type, player_on_second, match_result, match_moves)

	$ScrollContainer/VBoxContainer.add_child(game_entry)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
