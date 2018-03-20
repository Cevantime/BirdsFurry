extends CanvasLayer

signal game_restarted

func _ready():
	$PanelContainer.hide()
	$RestartButton.hide()
	
func show():
	$PanelContainer.show()
	$RestartTimer.start()

func _on_Button_pressed():
	emit_signal("game_restarted")


func _on_RestartTimer_timeout():
	$PanelContainer.get_node("Message").text = "Restart ?"
	$RestartButton.show()
