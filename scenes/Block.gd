extends "Damageable.gd"

onready var regions = $TextureRects.regions

func _process(delta):
	$Texture.region_rect = get_current_region()
	
func get_regions():
	return regions

func get_current_region():
	return regions[get_current_region_index()]
	
func get_current_region_index():
	var regions_size = regions.size();
	var health_ratio = float(health) / float(max_health)
	return round(clamp(regions_size - ((health_ratio) * regions_size), 0, regions_size - 1))
	

