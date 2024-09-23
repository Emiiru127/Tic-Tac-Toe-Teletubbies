extends Node

var starting_player : int
var againstAI: bool

var database : SQLite
var current_match_id : int

var isDatabaseInitialized : bool

func _ready():
	starting_player = 1
	againstAI = false
	
	database = SQLite.new()
	database.path="res://data.db"
	database.open_db()
	
	if checkDatabase() == false:
		initializeGameDatabase()
	
func checkDatabase() -> bool:
	var check = database.select_rows("settingsTable", "initialized", ["*"])

	if len(check) == 0:
		return false
	
	return true
	
func initializeGameDatabase() -> void:
	
	var settingsTable = {
		"initialized" : {"data_type":"boolean"},
	}
	
	var gameHistoryTable = {
		"game_id" : {"data_type":"int", "primary_key":true, "not_null":true, "auto_increment":true},
		"match_type" : {"data_type":"text"},
		"player_on_second" : {"data_type":"boolean"},
		"result" : {"data_type":"text"},
		"moves" : {"data_type":"text"}
	}
	
	database.create_table("settingsTable", settingsTable)
	database.create_table("gameHistoryTable", gameHistoryTable)
	
	var settingsData = {
		
		"initialized" : true,
		
	}
	
	database.insert_row("settingsTable", settingsData)

func insertGameMatch(match_type : String, player_on_second : bool, match_result : String, match_moves : Array):
	
	var convertedMoves : String = ""
	
	var temp = 0
	for i in match_moves:
		
		if temp < (match_moves.size() - 1):
			convertedMoves += i + ":"
		else :
			convertedMoves += i 
			
		temp += 1
	
	var gameData = {
		
		"match_type" : match_type,
		"player_on_second" : player_on_second,
		"result" : match_result,
		"moves" : convertedMoves
		
	}
	
	database.insert_row("gameHistoryTable", gameData)

func set_player(player : int) -> void:
	starting_player = player
	print("Change Player to: " + str(player)) 
