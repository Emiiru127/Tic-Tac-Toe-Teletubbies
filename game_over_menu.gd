extends CanvasLayer


signal restart
signal go_menu

func _on_restart_button_pressed() -> void:
	restart.emit()


func _on_menu_button_pressed() -> void:
	GlobalData.againstAI = false
	go_menu.emit()
