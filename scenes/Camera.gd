extends Camera2D

var drag_cam = false
var old_mouse_pos

export(int) var CAMERA_SPEED = 2
export(float, 0.5, 5) var zoom_min = 1
export(float, 2, 10) var zoom_max = 2
export(int, 1, 10) var zoom_speed = 2

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process(delta):
	
	var mouse_pos = get_global_mouse_position()
	
	if Input.is_action_just_pressed("drag_cam") : 
		drag_cam = true
		old_mouse_pos = mouse_pos
	
	if Input.is_action_just_released("drag_cam") :
		drag_cam = false
		
	if drag_cam :
		var mouse_move = (old_mouse_pos - mouse_pos) * CAMERA_SPEED
		position = clamp_position(position + mouse_move)
		old_mouse_pos = mouse_pos
		
		

func clamp_position(pos) :
	var viewport_radius = get_viewport_rect().size / 2 * zoom
	pos.x = clamp(pos.x, limit_left + viewport_radius.x, limit_right - viewport_radius.x)
	pos.y = clamp(pos.y, limit_top + viewport_radius.y, limit_bottom - viewport_radius.y)
	return pos
	
func _input(event):
	var z = zoom.x
	if event.is_action("zoom_in") :
		z -= 0.01 * zoom_speed
	if event.is_action("zoom_out") :
		z += 0.01 * zoom_speed
		
	z = clamp(z, zoom_min, zoom_max)
	
	zoom = Vector2(z,z)
