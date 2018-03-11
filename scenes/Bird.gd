extends RigidBody2D

var state = "idle"


func _process(delta):
	print(state)
	if Input.is_action_just_released("touch") :
		state = "idle"
		print("idle")
	
func _integrate_forces(s):
	if state == "dragged" :
		print("integrate dragged")
		s.linear_velocity = get_local_mouse_position() * 10
		

func _input_event(viewport, event, shape_idx):
	if event.is_action_pressed("touch"):
		state = "dragged"
		print("dragged begin")
	
		
