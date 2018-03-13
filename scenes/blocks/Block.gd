extends RigidBody2D

export(int, 0, 100) var max_health = 10

onready var health = max_health

onready var regions = $TexturesRects.regions

func _process(delta):
	$Texture.region_rect = get_current_region()
	

func get_damage(damage):
	health -= int(damage)
	if(health <= 0):
		disappear()
	
func get_regions():
	return regions

func get_current_region():
	return regions[get_current_region_index()]
	
func get_current_region_index():
	return clamp(regions.size() - ((health / max_health) * regions.size()), 0, regions.size() - 1)
	
func disappear():
	queue_free()


func _on_Block_body_entered( other ):
	var damage = 0
	if(other.has_method("get_damage")):
		var velocity = other.linear_velocity + linear_velocity
		damage = (other.mass + mass) * velocity.length() / 40
		other.get_damage(damage)
	else :
		damage = mass * linear_velocity.length()  / 40
		
	get_damage(damage)
