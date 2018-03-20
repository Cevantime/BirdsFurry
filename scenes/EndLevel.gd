extends CanvasLayer

export var score_steps = {
	"1": 10000,
	"2": 15000,
	"3": 20000
}

signal game_restarted

var animated_score = 0

func _ready():
	for child in get_children():
		if child.has_method("hide"): child.hide()

func _process(delta):
	if animated_score > score_steps["1"] :
		$Star1.get_node("TextureRect2").show()
	if animated_score > score_steps["2"] :
		$Star2.get_node("TextureRect2").show()
	if animated_score > score_steps["3"] :
		$Star3.get_node("TextureRect2").show()
		
	$Score.text = str(int(animated_score))

func start(score):
	for child in get_children():
		if child.has_method("show") : child.show()
	$Tween.interpolate_property(self, "animated_score", animated_score, score, 2.5, Tween.TRANS_LINEAR,Tween.EASE_IN)
	if  ! $Tween.is_active() :
		$Tween.start()


func _on_TextureButton_pressed():
	emit_signal("game_restarted")
