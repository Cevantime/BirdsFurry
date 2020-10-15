extends RigidBody2D

enum {
	STATE_IDLE = 1, 
	STATE_TRANSFER = 2,
	STATE_DRAGGED = 4, 
	STATE_BEING_LAUNCHED = 8, 
	STATE_LAUNCHED = 16, 
	STATE_TOUCHED = 32, 
	STATE_CRASHED = 64
}

var state = STATE_IDLE

func _process(delta):
	
	if Input.is_action_just_released("touch") :
		if state == STATE_DRAGGED :
			state = STATE_IDLE
			


func _input_event(viewport, event, shape_idx):
	
	if event.is_action_pressed("touch") :
		print("pressed")
		state = STATE_DRAGGED
		
		
func _integrate_forces(s):
	
		if state == STATE_DRAGGED :
			
			var player_force = (get_global_mouse_position() - $'../AttachPoint'.global_position) 
			
			var max_player_force = 5000
			
			player_force = player_force.clamped(max_player_force)
			var lv = player_force
			s.linear_velocity += lv
	