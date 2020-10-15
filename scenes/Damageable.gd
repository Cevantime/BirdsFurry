extends RigidBody2D

export(int, 1, 1000) var health = 10
export(PackedScene) var explosion_scene: PackedScene = preload("res://scenes/Explosion.tscn")
export(int, 0, 100000) var destroy_points = 500
export(int, 0, 100000) var survive_points = 0
var processed_velocity = Vector2()
var processed_angular_velocity = Vector2()
onready var max_health = health

signal exploded

func _ready():
	update_animation()
	
func _physics_process(delta):
	self.processed_velocity = self.linear_velocity
	self.processed_angular_velocity = self.angular_velocity

func _integrate_forces(state):
	var contact_counts = {}
	for i in range(0, state.get_contact_count()) :
		var contact_id = state.get_contact_collider_id(i)
		if not contact_counts.has(contact_id) :
			contact_counts[contact_id] = 1
		else :
			contact_counts[contact_id] += 1
	
	for i in range(0, state.get_contact_count()) :
		var contact = state.get_contact_collider_object(i)
		var contact_velocity = state.get_contact_collider_velocity_at_position(i)
		var R = state.get_contact_local_position(i) - self.global_position
		var self_velocity = self.processed_velocity + self.processed_angular_velocity * Vector2(-R.y, R.x)
		var v = contact_velocity - self_velocity
		var m_self = self.mass
		var m_contact = contact.mass if contact is RigidBody2D else 100000000
		var p = v.dot(state.get_contact_local_normal(i)) * (m_contact / (m_self + m_contact)) / contact_counts[contact.get_instance_id()]
		get_damage(p * 0.06)

func _on_Damageable_body_entered( body ):
	# get_damage(self.processed_velocity.length() * 0.05)
	pass

func get_damage(damage) : 
	damage = round(damage)
	if damage > 0 :
		print("damage : ", damage)
		self.health -= damage
		update_animation()
		if self.health <= 0: 
			explode()
			
func update_animation() :
	if $AnimationPlayer.get_animation_list().size() > 0:
		var h_ratio = float(health) / float(max_health)
		var current_animation_index = max(ceil(h_ratio * $AnimationPlayer.get_animation_list().size()) - 1, 0)
		$AnimationPlayer.play($AnimationPlayer.get_animation_list()[current_animation_index])
		
func explode(emit_signals = true):
	var explosion = explosion_scene.instance()
	explosion.position = position
	get_parent().add_child(explosion)
	if emit_signals: 
		emit_signal("exploded", self)
	queue_free()
