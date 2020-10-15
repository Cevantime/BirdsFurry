extends CanvasLayer

signal restart_level

func _ready():
	$PanelContainer.hide()
	$RestartButton.hide()
	
func display():
	yield(get_tree().create_timer(1), "timeout")
	$PanelContainer.show()
	yield(get_tree().create_timer(2), "timeout")
	$RestartButton.show()
	$PanelContainer/Message.text = "Restart ?"

func _on_RestartButton_pressed():
	emit_signal("restart_level")
