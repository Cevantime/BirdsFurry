extends "res://scenes/Damageable.gd"

enum {
	STATE_IDLE,
	STATE_TRANSFERED,
	STATE_ATTACHED,
	STATE_DRAGGED,
	STATE_RELEASED,
	STATE_LAUNCHED,
	STATE_TOUCHED
}

var state = STATE_IDLE
var impulse = null
var slingshot = null

export(int, 60, 2000) var TRANSFER_SPEED = 300

signal eliminated
signal launched
	
func _integrate_forces(s):
	._integrate_forces(s)
	
	if state == STATE_TOUCHED and self.processed_velocity.length() < 2 :
		emit_signal("eliminated", self)
		state = STATE_IDLE
	
	if state == STATE_IDLE:
		return
		
	if s.get_contact_count() > 0 and state == STATE_LAUNCHED :
		state = STATE_TOUCHED
	
	var launch_pos = slingshot.get_node("LaunchPoint").get_global_position()
	var diff_pos = launch_pos - get_global_position()
	if Input.is_action_just_released("touch") and state == STATE_DRAGGED :
		impulse = slingshot.get_impulse()
		state = STATE_RELEASED if impulse.x > 0 else STATE_ATTACHED
	var lv = s.get_linear_velocity()
	var av = s.get_angular_velocity()
	var delta = 1 / s.get_step()
	
	# IMPLEMENT STATES
	match state : 
		STATE_TRANSFERED:
			if diff_pos.length() * delta < TRANSFER_SPEED:
				lv = diff_pos * delta
				state = STATE_ATTACHED
				slingshot.attach_bird(self)
			else :
				lv = diff_pos.normalized() * TRANSFER_SPEED
		STATE_ATTACHED:
			lv = diff_pos * 20
			av = - rotation * delta
		STATE_DRAGGED:
			var player_force = get_global_mouse_position() - launch_pos
			var angle = diff_pos.angle()
			av = (angle - rotation) * delta
			if angle < -1.2 and angle > -2 :
				player_force = player_force.clamped(10)
			else : 
				player_force = player_force.clamped(100)
			lv = (player_force + diff_pos) * 20
		STATE_RELEASED:
			if diff_pos.length() * delta < impulse.length() :
				state = STATE_LAUNCHED
				slingshot.detach_bird()
				emit_signal("launched", self)
			else : 
				lv = diff_pos.normalized() * impulse.length()
		STATE_LAUNCHED:
			av = (lv.angle() - rotation) * delta
	
	s.set_linear_velocity(lv)
	s.set_angular_velocity(av)

func attach_to(slingshot) :
	self.slingshot = slingshot
	state = STATE_TRANSFERED
	
func _input_event(viewport, event, shape_idx):
	if event.is_action_pressed("touch") and state == STATE_ATTACHED:
		state = STATE_DRAGGED
