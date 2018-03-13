extends Node2D

export(float, 5, 15) var strength = 9

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
		attached_pos = attached_bird.get_node("AttachPoint").get_global_transform().origin
	else :
		attached_pos = $LaunchPoint.get_global_transform().origin
		
	var elastic_pos_front = elactic.get_node("ElasticPoint").get_global_transform().origin;
	var diff = attached_pos - elastic_pos_front
	var middle_front = diff * 0.5
	var sprite = elactic.get_node("Elastic");
	sprite.position = middle_front
	sprite.scale.x = - middle_front.length() * 0.0075
	sprite.rotation = middle_front.angle()
	

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
