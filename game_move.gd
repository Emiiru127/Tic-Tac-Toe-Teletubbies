extends MarginContainer

func set_data(gameData : Array, player : String, move_number : int, move : String):
	
	var data1 : String = " " + gameData[0][0] + " | " + gameData[0][1] + " | " + gameData[0][2] + " \n"
	var data2 : String = "—————\n"
	var data3 : String = " " + gameData[1][0] + " | " + gameData[1][1] + " | " + gameData[1][2] + " \n"
	var data4 : String = "—————\n"
	var data5 : String = " " + gameData[2][0] + " | " + gameData[2][1] + " | " + gameData[2][2] + " \n"
	var data6 : String = player
	var data7 : String = "Move #" + str(move_number) + "\n"
	var data8 : String = "(" + move + ")" + "\n"

	var data = data7 + data8 + data1 + data2 + data3 + data4 + data5 + data6
	
	$Label.text = data
	
