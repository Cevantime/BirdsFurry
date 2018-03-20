extends "Damageable.gd"

func get_current_animation():
	return $AnimationPlayer.get_animation_list()[get_current_animation_index()]
	
func get_current_animation_index():
	var animations_size = $AnimationPlayer.get_animation_list().size();
	var health_ratio = float(health) / float(max_health)
	return round(clamp(animations_size - ((health_ratio) * animations_size), 0, animations_size - 1))

func get_damage(damage):
	.get_damage(damage)
	$AnimationPlayer.play(get_current_animation())