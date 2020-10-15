extends Node

var max_score = 0
var score = 0
var unlaunched_birds
var game_ended = false

func _ready():
	
	for damageable in get_tree().get_nodes_in_group("Damageable") :
		damageable.connect("exploded", self, "_on_Damageable_exploded")
		max_score += max(damageable.destroy_points, damageable.survive_points)
	
	unlaunched_birds = get_tree().get_nodes_in_group("Bird")
	
	var current_bird = change_bird()
	
	max_score -= current_bird.survive_points
	
	$GUI.set_max_score(max_score)

func _on_Damageable_exploded(damageable) :
	score += damageable.destroy_points
	$GUI.set_score(score)
	yield(get_tree(), "idle_frame")
	var ennemies = get_tree().get_nodes_in_group("Ennemy")
	if ennemies.size() == 0:
		prepare_end()
		
func _on_Bird_eliminated(bird) :
	var current_bird = change_bird()
	if ! current_bird :
		prepare_end()

func _on_Bird_launched(bird):
	unlaunched_birds.pop_front()
	
func change_bird():
	if unlaunched_birds.size() == 0:
		return null
	var current_bird = unlaunched_birds[0]
	current_bird.connect("eliminated", self, "_on_Bird_eliminated")
	current_bird.connect("launched", self, "_on_Bird_launched")
	current_bird.attach_to($Slingshot)
	$Camera.position = $Slingshot/ElasticBack/FixationPoint.global_position
	return current_bird
	
func prepare_end():
	$GUI.display_end_button()
	
func end_game():
	if game_ended :
		return
	game_ended = true
	if get_tree().get_nodes_in_group("Ennemy").size() > 0:
		$Gameover.display()
		return
	while unlaunched_birds.size() > 0:
		var bird = unlaunched_birds.pop_front()
		score += bird.survive_points
		bird.explode(false)
	$GUI.set_score(score)
	yield(get_tree().create_timer(2), "timeout")
	$EndLevel.display(score)
	
func restart_level():
	get_tree().reload_current_scene()

func _on_GUI_end_game():
	end_game()

func _on_EndLevel_restart_level():
	restart_level()

func _on_Gameover_restart_level():
	restart_level()
