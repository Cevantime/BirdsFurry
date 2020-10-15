extends Node2D

export(float, 2, 10) var strength = 6
export(int, 1, 10) var strechness = 5

var attached_bird

func _process(delta):
	
	update_elastic_pos($Elastic1)
	update_elastic_pos($Elastic2)
		

	
func get_strength():
	return strength
	
func attach_bird(bird):
	attached_bird = bird
	
func detach_bird() :
	attached_bird = null
	
func update_elastic_pos(elactic) :
	var attached_pos = null
	if attached_bird != null :
		attached_pos = attached_bird.get_node("AttachPoint").global_position
	else :
		attached_pos = $LaunchPoint.global_position
		
	var elastic_pos_front = elactic.get_node("ElasticPoint").global_position
	var diff = attached_pos - elastic_pos_front
	var middle_front = diff * 0.5
	var sprite = elactic.get_node("Elastic");
	sprite.position = middle_front
	sprite.scale.x = - middle_front.length() * 0.01
	sprite.rotation = middle_front.angle()
	
func get_strechness():
	return strechness
