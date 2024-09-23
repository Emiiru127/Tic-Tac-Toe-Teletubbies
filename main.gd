extends Node

@export var circle_scene: PackedScene
@export var cross_scene: PackedScene

var board_width: int
var board_height: int

var board_x_start_offset: int
var board_y_start_offset: int

var board_x_end_offset: int
var board_y_end_offset: int

var board_true_x_end: int
var board_true_y_end: int

var board_true_width: int
var board_true_height: int

var grid_pos: Vector2i

var cell_size: int

var player: int
var grid_data: Array

var temp_marker 
var player_panel_pos : Vector2i 

var row_sum : int
var col_sum : int
var diagonal1_sum : int
var diagonal2_sum : int
var winner : int
var moves : int

var ai_player : int

const INF = 1000

var match_type : String
var player_on_second : bool
var match_result : String
var match_moves : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	board_width = $Board.texture.get_width() + ($Board.texture.get_width() * 0.25)
	board_height = $Board.texture.get_height() + ($Board.texture.get_height() * 0.25)
	
	board_x_start_offset = 90
	board_y_start_offset = 70
	
	board_x_end_offset = 398
	board_y_end_offset = 179
	
	board_true_x_end = 502
	board_true_y_end = 425
	
	board_true_width = board_true_x_end - board_x_start_offset
	board_true_height = board_true_y_end - board_y_start_offset
	
	cell_size = board_true_height / 3
	
	player_panel_pos = $NextPlayerPanel.get_position()
	
	print(board_true_width/3)
	print(board_true_height/3)
	
	player = GlobalData.starting_player if GlobalData.againstAI == true and GlobalData.starting_player == -1 else 1
	
	if GlobalData.againstAI:
		ai_player = -player 
	
	new_game()
		
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func new_game() -> void:
	grid_data = [
		[0, 0, 0],
		[0, 0, 0],
		[0, 0, 0]
	]
	player = GlobalData.starting_player if GlobalData.againstAI == true and GlobalData.starting_player == -1 else 1
	winner = 0
	moves = 0
	row_sum = 0
	col_sum = 0
	diagonal1_sum = 0
	diagonal2_sum = 0
	
	match_type = "Player vs AI" if GlobalData.againstAI else "Player vs Player"
	player_on_second = true if GlobalData.starting_player == -1 else false
	match_result = ""
	match_moves = []

	get_tree().call_group("circles", "queue_free")
	get_tree().call_group("crosses", "queue_free")
	
	$GameOvePanel.hide()
	get_tree().paused = false
	print("PLAYER: " + str(player))
	create_marker(player, player_panel_pos + Vector2i((cell_size / 2 + cell_size / 8), (cell_size / 2 + cell_size / 8)), true)
	
	if GlobalData.starting_player == -1 and GlobalData.againstAI == true:
		best_move()  # Let AI make the first move


func _on_game_ove_panel_restart() -> void:
	new_game() # Replace with function body.
	
	
func _on_game_ove_panel_go_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")


func create_marker(player: int, position: Vector2, temp : bool = false) -> void:
	if player == 1:
		var circle = circle_scene.instantiate()
		circle.position = position
		add_child(circle)
		if temp : temp_marker = circle
	if player == -1:
		var cross = cross_scene.instantiate()
		cross.position = position
		add_child(cross)
		if temp : temp_marker = cross
		
func game_over() -> void:
	print("Game Over!!!")
	print("Winner: " + "Player 1" if winner == 1 else "Player 2")
	get_tree().paused = true
	$GameOvePanel.show()
	
	if winner == 1:
		
		if GlobalData.againstAI : 
			match_result = "Player" if GlobalData.starting_player == 1 else "AI" 
			$GameOvePanel.get_node("winner_label").text = "PLAYER WINS!" if GlobalData.starting_player == 1 else "AI WINS!"
		else :
			match_result = "Player 1"
			$GameOvePanel.get_node("winner_label").text = "PLAYER 1 WINS!"
	elif winner == -1:
		
		if GlobalData.againstAI : 
			match_result = "Player" if GlobalData.starting_player == -1 else "AI" 
			$GameOvePanel.get_node("winner_label").text = "PLAYER WINS!" if GlobalData.starting_player == -1 else "AI WINS!"
		else :
			match_result = "Player 2"
			$GameOvePanel.get_node("winner_label").text = "PLAYER 2 WINS!"
	elif winner == 0:
		$GameOvePanel.get_node("winner_label").text = "DRAW!!!"
		match_result = "DRAW"
		
	
	
	GlobalData.insertGameMatch(match_type, player_on_second, match_result, match_moves)
	

func check_win() -> int:
	for i in range(3):
		# Reset the sums at the beginning of each loop iteration
		row_sum = grid_data[i][0] + grid_data[i][1] + grid_data[i][2]
		col_sum = grid_data[0][i] + grid_data[1][i] + grid_data[2][i]

		# Check rows and columns
		if row_sum == 3 or col_sum == 3:
			winner = 1
			return winner  # Player 1 wins
		elif row_sum == -3 or col_sum == -3:
			winner = -1
			return winner  # Player 2 wins 

	# Check diagonals separately (only once per game)
	diagonal1_sum = grid_data[0][0] + grid_data[1][1] + grid_data[2][2]
	diagonal2_sum = grid_data[0][2] + grid_data[1][1] + grid_data[2][0]

	if diagonal1_sum == 3 or diagonal2_sum == 3:
		winner = 1
		return winner  # Player 1 wins
	elif diagonal1_sum == -3 or diagonal2_sum == -3:
		winner = -1
		return winner  # Player 2 wins 

	return 0  # No winner yet
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if event.position.x > board_x_start_offset and event.position.y > board_y_start_offset:
				if event.position.x < board_true_x_end and event.position.y < board_true_y_end:
					
					grid_pos = estimatePosition(event.position)

					if grid_data[grid_pos.y][grid_pos.x] != 0:
						print("YAHALLO ALREADY HAS DATA: " + str(grid_data[grid_pos.y][grid_pos.x]))
						return

					moves += 1
					grid_data[grid_pos.y][grid_pos.x] = player
					print("YAHALLO2 PLAYER: " + str(player))
					var temp_move : String = str(grid_pos.x) + "," + str(grid_pos.y)
						
					if  match_moves.has(temp_move) == false:
						match_moves.append(temp_move)
					
					grid_pos = estimatePositionOffset(grid_pos)
					
					create_marker(player, grid_pos)
					

					if check_win() != 0 or moves == 9:
						print(check_win())
						print(moves)
						game_over()
					else:
						if !GlobalData.againstAI:
							player *= -1
						temp_marker.queue_free()
						create_marker(player, player_panel_pos + Vector2i((cell_size / 2 + cell_size / 8), (cell_size / 2 + cell_size / 8)), true)

					# If against AI, make the AI's move
					if GlobalData.againstAI and winner == 0 and moves < 9:
						#print("Make AI best move")
						best_move()
				
					print(grid_data[0])
					print(grid_data[1])
					print(grid_data[2])
					
					print("Player is " + str(player))
					print("Ai is " + str(ai_player))
					
func estimatePosition (position) -> Vector2i:
	position.x = position.x - board_x_start_offset
	position.y = position.y - board_y_start_offset
	position = Vector2i(position / (cell_size + 5))
	if position.x > 2:
		position.x = 2
	if position.y > 2:
		position.y = 2
	
	return position

func estimatePositionOffset (position) -> Vector2i:
	var temp_x_grid = position.x
	var temp_y_grid = position.y

	position.x = board_x_start_offset
	position.y = board_y_start_offset

	position.x += cell_size * temp_x_grid
	position.y += cell_size * temp_y_grid

	position.x += cell_size / 2
	position.y += cell_size / 2

	if temp_x_grid == 0:
		position.x -= 20

	if temp_x_grid == 2:
		position.x += 15

	position.x += 30
	position.y -= 2.5
	
	return position
					

func minimax(board: Array, depth: int, is_maximizing: bool, alpha: int, beta: int) -> int:
	# Check for terminal states
	var winner = check_win_simulation(board)
	
	if winner == ai_player:
		return INF - depth  # AI wins, faster win is better
	elif winner == player:
		return -INF + depth  # Player wins, slower loss is better
	elif is_board_full(board):
		return 0  # Draw

	if is_maximizing:
		var best_score = -INF
		for y in range(3):
			for x in range(3):
				if board[y][x] == 0:  # Empty spot
					board[y][x] = ai_player  # Try move
					var score = minimax(board, depth + 1, false, alpha, beta)
					board[y][x] = 0  # Undo move
					best_score = max(score, best_score)
					alpha = max(alpha, best_score)
					if beta <= alpha: 
						break  # Alpha-beta pruning
		return best_score
	else:
		var best_score = INF
		for y in range(3):
			for x in range(3):
				if board[y][x] == 0:  # Empty spot
					board[y][x] = player  # Try move
					var score = minimax(board, depth + 1, true, alpha, beta)
					board[y][x] = 0  # Undo move
					best_score = min(score, best_score)
					beta = min(beta, best_score)
					if beta <= alpha:
						break  # Alpha-beta pruning
		return best_score

func best_move() -> void:
	var best_score = -INF
	var move = Vector2i()
	var temp_grid = copy_grid_data(grid_data)

	for y in range(3):
		for x in range(3):
			if temp_grid[y][x] == 0:  # Empty cells
				temp_grid[y][x] = ai_player  # AI simulates move
				var score = minimax(temp_grid, 0, false, -INF, INF)
				temp_grid[y][x] = 0  # Undo simulated move
				if score > best_score:
					best_score = score
					move = Vector2i(x, y)

	# AI makes the best move found
	grid_data[move.y][move.x] = ai_player
	var temp_move : String = str(move.x) + "," + str(move.y)

	if  match_moves.has(temp_move) == false:
		match_moves.append(temp_move)
	create_marker(ai_player, estimatePositionOffset(Vector2i(move.x, move.y)))
	
	moves += 1

	# Check for game over conditions
	if check_win() != 0 or moves == 9:
		game_over()

	# Toggle player turn if not AI vs AI
	if !GlobalData.againstAI:
		player *= -1


# Helper function to create a copy of the grid_data
func copy_grid_data(original_grid: Array) -> Array:
	var new_grid = []
	for row in original_grid:
		new_grid.append(row.duplicate())
	return new_grid

func check_win_simulation(board: Array) -> int:
	
	var row_sum: int
	var col_sum: int
	var diagonal1_sum: int = 0
	var diagonal2_sum: int = 0
	
	# Check rows and columns for a win
	for i in range(3):
		row_sum = board[i][0] + board[i][1] + board[i][2]
		col_sum = board[0][i] + board[1][i] + board[2][i]
		
		if row_sum == 3 or col_sum == 3:
			return 1  # AI wins
		elif row_sum == -3 or col_sum == -3:
			return -1  # Player wins
		
	# Check diagonals for a win
	diagonal1_sum = board[0][0] + board[1][1] + board[2][2]
	diagonal2_sum = board[0][2] + board[1][1] + board[2][0]
	
	if diagonal1_sum == 3 or diagonal2_sum == 3:
		return 1  # AI wins
	elif diagonal1_sum == -3 or diagonal2_sum == -3:
		return -1  # Player wins
	
	# If no winner, return 0 (no win yet)
	return 0

func is_board_full(board: Array) -> bool:
	for row in board:
		for cell in row:
			if cell == 0:  # Check for an empty cell
				return false  # Board is not full
	return true  # Board is full
