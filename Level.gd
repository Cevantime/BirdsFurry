extends Node2D

var bird = null
var camera = null
var drag_cam = false
var old_mouse_pos = null
var spots = []
var birds = []

export(PackedScene) var spot_scene
export(float) var zoom_min = 0.5
export(float) var zoom_max = 2
export(int, 1, 20) var zoom_speed = 5

func _ready():
	camera = $Camera2D
	birds = $Birds.get_children()
	change_bird()
	camera.current = true
	camera.position = $Slingshot/LaunchPoint.global_position
	bird.attach_to($Slingshot)
	old_mouse_pos = get_global_mouse_position()

func _process(delta):
	var d_cam_pos = get_global_mouse_position() - old_mouse_pos
	old_mouse_pos = get_global_mouse_position()
	
	if(drag_cam) :
		camera.position -= d_cam_pos
	
		
	if Input.is_action_just_pressed("drag_cam"):
		drag_cam = true
	if Input.is_action_just_released("drag_cam"):
		drag_cam = false
	
	clamp_zoom()
	
func _physics_process(delta):
	if bird.is_dragged():
		clean_spots()
		draw_trajectory()

func change_bird():
	if birds.size() == 0 :
		print("level end")
	else :
		print("attach")
		bird = birds.pop_front()
		bird.attach_to($Slingshot)
		camera.position = bird.position

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
	var start_pos = $Slingshot.position + $Slingshot/LaunchPoint.position
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


func _on_Bird_crashed():
	change_bird()
	clean_spots()
	
func _on_Bird_touched():
	$TrajectoryTimer.stop()


func _on_TrajectoryTimer_timeout():
	if(bird.is_launched()) :
		draw_spot(bird.position)

func _on_Bird_launched( impulse ):
	$TrajectoryTimer.start()
	clean_spots()
