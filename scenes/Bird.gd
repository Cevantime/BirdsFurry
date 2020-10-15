extends "Damageable.gd"

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

var attached_slingshot = null

var target_slingshot = null

var initial_impulse = null

export(int,0,100000) var remaining_score = 5000
export(int, 300, 1000) var transfer_speed = 500

onready var player_force = Vector2(0,0)

signal launched(impulse)
signal crashed
signal touched

func _ready():
	$AnimationTimer.wait_time = randf() * 3
	$AnimationTimer.start()

func _process(delta):
	
	if is_transfering() :
		var launch_point = target_slingshot.get_node("LaunchPoint").global_position
		var to_launchpoint = global_position - launch_point
		if to_launchpoint.length() < 10:
			attach_to(target_slingshot)
			state = STATE_IDLE
		else : 
			linear_velocity = -to_launchpoint.normalized() * transfer_speed
	
	if Input.is_action_just_released("touch") : 
		if state == STATE_DRAGGED && attached_slingshot != null :
			initial_impulse = get_impulse()
			if(initial_impulse.x < 0):
				state = STATE_IDLE
			else :
				state = STATE_BEING_LAUNCHED

	
func get_old_velocity():
	return old_velocity
	
func get_remaining_score():
	return remaining_score

func _integrate_forces(s):
	
	if is_attached() :
		var lv = Vector2(0,0)
		
		var impulse = get_impulse()
		var launch_point = attached_slingshot.get_node("LaunchPoint")
		
		lv += impulse * attached_slingshot.get_strechness()
		
		if state == STATE_DRAGGED :
			var angle = impulse.angle()
			
			var player_force = (get_global_mouse_position() - launch_point.global_position) * attached_slingshot.get_strength() * attached_slingshot.get_strechness()
			var max_player_force = attached_slingshot.get_strength() * 100 * attached_slingshot.get_strechness()
			if( angle > -1.97 and angle < -1.2 ) :
				max_player_force /= 10
			player_force = player_force.clamped(max_player_force)
			lv += player_force
		
		
		if state == STATE_BEING_LAUNCHED:
			var diff_pos = (launch_point.global_position - global_position)
			lv = initial_impulse
			if(diff_pos.length() < 5) :
				initial_impulse = null
				launch(lv)
		
		if(impulse.length() > 20):
			angular_velocity = angle_between(impulse.angle(), rotation) * 100
			
		s.set_linear_velocity(lv)
	
	elif is_launched() and s.get_contact_count() == 0 :
		angular_velocity = angle_between(s.linear_velocity.angle(), rotation) * 100
	
	elif is_touched() :
		if s.linear_velocity.length() < 7 : 
			crash()
			
	s.set_angular_velocity(angular_velocity)
	
func _input_event(viewport, event, shape_idx):
	if event.is_action_pressed("touch") && state == STATE_IDLE && is_attached():
		state = STATE_DRAGGED
	
func is_dragged():
	return state == STATE_DRAGGED
	
func is_launched():
	return state == STATE_LAUNCHED

func is_touched():
	return state == STATE_TOUCHED
	
func is_transfering():
	return state == STATE_TRANSFER
	
func is_attached():
	return attached_slingshot != null
	
func launch(lv):
	connect("body_entered", self, "_on_Body_entered")
	state = STATE_LAUNCHED
	emit_signal("launched", lv)
	detach()

func touch():
	state = STATE_TOUCHED
	emit_signal("touched")

func crash():
	state = STATE_CRASHED
	emit_signal("crashed")
	
func next(slingshot):
	state = STATE_TRANSFER
	target_slingshot = slingshot
	
	
func detach():
	attached_slingshot.detach_bird()
	attached_slingshot = null
	
func attach_to(slingshot):
	attached_slingshot = slingshot
	attached_slingshot.attach_bird(self)
	
func get_impulse() :
	return -(global_position - attached_slingshot.get_node("LaunchPoint").global_position) * attached_slingshot.get_strength()
	
func _on_AnimationTimer_timeout():
	$AnimationPlayer.current_animation = "idle"
	$AnimationPlayer.play()
	
func _on_Body_entered(other):
	if(is_launched()):
		touch()
	if(other.has_method("get_damage_from")):
		other.get_damage_from(self)
		
func angle_between(a1, a2):
	var a = a1 - a2
	if a > PI : a -= 2 * PI
	if a < -PI : a += 2 * PI
	return a
