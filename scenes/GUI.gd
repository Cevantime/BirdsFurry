extends CanvasLayer

signal game_ended

onready var container1 = $MarginContainer/VBoxContainer/MarginContainer/MarginContainer/HBoxContainer
onready var container2 = $MarginContainer/VBoxContainer/HBoxContainer2
onready var scoreProgress = container1.get_node("ScoreProgress")
onready var scoreMax = container1.get_node("ScoreMax")
onready var scoreValue = container1.get_node("ScoreValue")
onready var endLevelButton = container2.get_node("EndLevelButton")

func _ready():
	endLevelButton.hide()

func set_score(score):
	scoreValue.text = str(int(score))
	scoreProgress.value = int(score)
	
func set_max_score(max_score):
	scoreMax.text = str(max_score)
	scoreProgress.max_value = max_score

func _on_EndLevelButton_pressed():
	endLevelButton.hide()
	emit_signal("game_ended")

func display_end_control():
	endLevelButton.show()
