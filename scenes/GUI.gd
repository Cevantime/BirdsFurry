extends CanvasLayer

onready var score_progress = $MarginContainer/VBoxContainer/NinePatchRect/HBoxLeft/ScoreProgress
onready var score_max_label = $MarginContainer/VBoxContainer/NinePatchRect/HBoxRight/ScoreMax
onready var score_value_label = $MarginContainer/VBoxContainer/NinePatchRect/HBoxRight/ScoreValue
onready var tween_score = $TweenScore
onready var end_button = $MarginContainer/VBoxContainer/EndButton

var animated_score = 0

signal end_game

func _ready():
	end_button.self_modulate.a = 0
	end_button.disabled = true
	
func _process(delta):
	score_progress.value = animated_score
	score_value_label.text = str(int(animated_score))

func set_max_score(score_max):
	score_progress.max_value = score_max
	score_max_label.text = str(score_max)
	
func set_score(score):
	tween_score.interpolate_property(self, "animated_score", animated_score, score, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
	if not tween_score.is_active():
		tween_score.start()
	
func display_end_button():
	end_button.self_modulate.a = 1
	end_button.disabled = false

func _on_EndButton_pressed():
	emit_signal("end_game")
