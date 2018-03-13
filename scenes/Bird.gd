extends RigidBody2D

enum {
	STATE_IDLE = 1, 
	STATE_DRAGGED = 2, 
	STATE_BEING_LAUNCHED = 4, 
	STATE_LAUNCHED = 8, 
	STATE_TOUCHED = 16, 
	STATE_CRASHED = 32
}

var state = STATE_IDLE

var attached_slingshot = null

var initial_impulse = null

export(PackedScene) var spot_scene

onready var player_force = Vector2(0,0)

signal launched(impulse)
signal crashed
signal touched

func _ready():
	randomize()
	$AnimationTimer.wait_time = randf() * 3
	$AnimationTimer.start()

func _process(delta):
	
	if Input.is_action_just_released("touch") :
		if state == STATE_DRAGGED :
			state = STATE_BEING_LAUNCHED
			initial_impulse = get_impulse()

func _integrate_forces(s):
	if is_attached() :
		var lv = Vector2(0,0)
		
		var attached_point = attached_slingshot.get_node("LaunchPoint")
		lv = (attached_point.position + attached_slingshot.position - position) * 50
		
		var impulse = get_impulse()
		
		if state == STATE_DRAGGED :
			var angle = impulse.angle()
			var max_player_force = 5000
			if( angle > -1.97 and angle < -1.2 ) :
				max_player_force = 500
			player_force = get_local_mouse_position()  * 50
			player_force = player_force.clamped(max_player_force)
			lv += player_force
		
		
		if(impulse.length() > 7):
			rotation = impulse.angle()
		
		if state == STATE_BEING_LAUNCHED:
			var diff_pos = (attached_point.position + attached_slingshot.position - position)
			print(diff_pos.length())
			if(diff_pos.length() < 4) :
				lv = initial_impulse
				initial_impulse = null
				launch(lv)	
			
			
		s.set_linear_velocity(lv)
	
	elif is_launched() and s.get_contact_count() == 0 :
		angular_velocity = (s.linear_velocity.angle() - rotation)
		rotation = s.linear_velocity.angle()
	
	elif is_touched() :
		if s.linear_velocity.length() < 7 : 
			crash()

func _input_event(viewport, event, shape_idx):
	if state == STATE_IDLE :
		if event.is_action_pressed("touch"):
			state = STATE_DRAGGED
	
func is_dragged():
	return state == STATE_DRAGGED
	
func is_launched():
	return state == STATE_LAUNCHED

func is_touched():
	return state == STATE_TOUCHED
	
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
	
func detach():
	attached_slingshot.detach_bird()
	attached_slingshot = null
	
func attach_to(slingshot):
	attached_slingshot = slingshot
	attached_slingshot.attach_bird(self)
	
func get_impulse() :
	return -player_force * 0.01 * attached_slingshot.get_strength()
	
func _on_AnimationTimer_timeout():
	$AnimationPlayer.current_animation = "idle"
	$AnimationPlayer.play()
	
func _on_Body_entered(other):
	if(is_launched()):
		touch()
	if(other.has_method("get_damage")):
		var damage = mass * linear_velocity.length() / 40
		other.get_damage(damage)
