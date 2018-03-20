extends Node

var bird = null
var camera = null
var drag_cam = false
var old_mouse_pos = null
var spots = []
var birds = []
var score = 0
var animated_score = 0

export(PackedScene) var spot_scene
export(float) var zoom_min = 0.5
export(float) var zoom_max = 2
export(int, 1, 20) var zoom_speed = 5

func _ready():
	randomize()
	camera = $Camera2D
	birds = $Birds.get_children()
	change_bird()
	camera.current = true
	camera.position = $Slingshot/LaunchPoint.global_position
	bird.attach_to($Slingshot)
	old_mouse_pos = $Background.get_global_mouse_position()
	var block; var ennemi
	var max_score = 0
	for block in $Blocks.get_children() :
		block.connect("exploded", self, "_on_Damageable_exploded")
	for ennemi in $Ennemies.get_children() :
		ennemi.connect("exploded", self, "_on_Damageable_exploded")
	for bird in $Birds.get_children() :
		bird.connect("crashed", self, "_on_Bird_crashed")
		bird.connect("touched", self, "_on_Bird_touched")
		bird.connect("launched", self, "_on_Bird_launched")
		
	max_score += compute_score($Ennemies)
	max_score += compute_score($Blocks)
	max_score += compute_score($Birds)
	
	max_score -= bird.get_remaining_score()
		
	$GUI.set_max_score(max_score)
	$GUI.set_score(0)

func _process(delta):
	var d_cam_pos = $Background.get_global_mouse_position() - old_mouse_pos
	old_mouse_pos = $Background.get_global_mouse_position()
	
	if(drag_cam) :
		var screen_size = get_viewport().size * camera.zoom / 2
		
		camera.position -= d_cam_pos
		
		camera.position.x = clamp(camera.position.x, camera.limit_left + screen_size.x, camera.limit_right - screen_size.x)
		camera.position.y = clamp(camera.position.y, camera.limit_top + screen_size.y, camera.limit_bottom - screen_size.y)

			
	if Input.is_action_just_pressed("drag_cam"):
		drag_cam = true
	if Input.is_action_just_released("drag_cam"):
		drag_cam = false
	
	clamp_zoom()
	
	$GUI.set_score(animated_score)
	
func _physics_process(delta):
	if weakref(bird).get_ref() and bird != null and bird.is_dragged():
		clean_spots()
		draw_trajectory()
		
func compute_score(node):
	var score = 0
	var child
	for child in node.get_children():
		score += compute_score(child)
		
	if node.has_method("get_remaining_score"):
		score += node.get_remaining_score()
	if node.has_method("get_score_value"):
		score += node.get_score_value()
		
	return score
			

func change_bird():
	bird = birds.pop_front()
	bird.attach_to($Slingshot)
	camera.position = bird.global_position
	bird.connect("exploded", self, "_on_Bird_exploded")

func clamp_zoom():
	if camera.zoom.x > zoom_max:
		camera.zoom = Vector2(zoom_max,zoom_max)
	elif camera.zoom.y < zoom_min:
		camera.zoom = Vector2(zoom_min, zoom_min)
		

func _input(event):
	var zoom_s = Vector2(1,1)
	zoom_s *= 0.01 * zoom_speed
	if event.is_action("zoom_in") :
		camera.zoom -= zoom_s
	if event.is_action("zoom_out") :
		camera.zoom += zoom_s
	
	clamp_zoom()

func draw_trajectory() :
	var impulse = bird.get_impulse()
	if(impulse.x > 0):
		var start_pos = $Slingshot/LaunchPoint.global_position
		for t in range(1, 11) :
			var tt = t * 0.5
			draw_spot(Vector2(impulse.x * tt + start_pos.x, 0.5 * 98 * tt * tt + impulse.y * tt + start_pos.y))
	
func clean_spots() :
	for spot in spots:
		spot.queue_free()
	spots = []
	
func draw_spot(pos) :
	var spot = spot_scene.instance()
	spot.position = pos
	spots.append(spot)
	add_child(spot)
	
func level_end() :
	$GUI.display_end_control()
	
func inc_score(score_inc):
	score += score_inc
	$Tween.interpolate_property(self, "animated_score", animated_score, score, 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN)
	if not $Tween.is_active():
		$Tween.start()
		
func reload_level():
	get_tree().reload_current_scene()

func _on_Bird_exploded(bird):
	_on_Bird_crashed()
	
func _on_Bird_crashed():
	clean_spots()
	$BirdchangeTimer.start()
	
func _on_Bird_touched():
	$TrajectoryTimer.stop()


func _on_TrajectoryTimer_timeout():
	if( weakref(bird).get_ref() and bird.is_launched()) :
		draw_spot(bird.global_position)

func _on_BirdchangeTimer_timeout():
	if $Ennemies.get_children().size() == 0 or birds.size() == 0 :
		level_end()
	
	else :
		change_bird()

func _on_Bird_launched( impulse ):
	$TrajectoryTimer.start()
	clean_spots()
	
func _on_Damageable_exploded(damageable):
	if damageable.has_method("get_score_value"):
		inc_score(damageable.get_score_value())


func _on_GUI_game_ended():
	if $Ennemies.get_children().size() == 0 :
		var bird
		for bird in birds:
			if bird.has_method("get_remaining_score"):
				bird.explose()
				inc_score(bird.get_remaining_score())
			
		$EndLevelTimer.start()
		
		
		
	elif birds.size() == 0:
		$GameOver.show()


func _on_GameOver_game_restarted():
	reload_level()


func _on_EndLevelTimer_timeout():
	$EndLevel.start(score)


func _on_EndLevel_game_restarted():
	reload_level()
