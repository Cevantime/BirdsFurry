extends RigidBody2D

export(int, 0, 100) var max_health = 10

export(int, 10, 100) var damage_intensity = 40

export(PackedScene) var explosion_scene

var old_velocity = Vector2(0,0)

var exploded = false

signal exploded(value)

export(int, 0,100000) var score_value = 0

onready var health = max_health

func _physics_process(delta):
	old_velocity = linear_velocity

func get_damage_from(other):
	var damage_mul = damage_intensity * 0.0015
	
	var velocity = old_velocity
	
	var damage = 0
	
	if(other.has_method("get_old_velocity")):
		velocity += other.get_old_velocity()
		damage = other.mass * velocity.length() * damage_mul
	else :
		damage = mass * velocity.length() * damage_mul
		 
	get_damage(damage)
		
func get_damage(damage) :
	health -= int(damage)
	if(health <= 0 and ! exploded):
		explose()
		
func explose():
	emit_signal("exploded", self)
	disappear()
	
func disappear():
	var expl = explosion_scene.instance()
	expl.position = self.position
	get_parent().add_child(expl)
	exploded = true
	queue_free()

func get_old_velocity():
	return old_velocity

func _on_Damageable_body_entered( body ):
	get_damage_from(body)
	
func get_score_value():
	return score_value
