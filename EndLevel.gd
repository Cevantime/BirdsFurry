extends CanvasLayer

export(Dictionary) var score_levels = {
	1: 5000,
	2: 10000,
	3: 15000
}

var animated_score

signal restart_level

func _ready():
	$Background.hide()
	set_process(false)
	
func _process(delta):
	for level in score_levels.keys():
		if animated_score >= score_levels[level]:
			get_node("Background/Star" + str(level)).show()
	$Background/Label.text = str(int(animated_score))

func display(score):
	animated_score = 0
	set_process(true)
	$Background.show()
	$TweenScore.interpolate_property(self, "animated_score", animated_score, score, 2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	if  ! $TweenScore.is_active():
		$TweenScore.start()


func _on_RestartButton_pressed():
	emit_signal("restart_level")
