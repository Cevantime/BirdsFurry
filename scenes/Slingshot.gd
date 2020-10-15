tool
extends Node2D

var bird
var BirdScript = preload("res://scenes/birds/Bird.gd")

export(int, 5, 15) var TRAJECTORY_SPOT_COUNT = 10
export(float, 0.2, 1, 0.1) var TRAJECTORY_TIME_STEP = 0.5
export(int, 1, 10) var STRENGTH = 5
export(int, 10, 100) var TRAJECTORY_IMPULSE = 75
export(int, -90, 90) var TRAJECTORY_ANGLE = 45
export(bool) var TRAJECTORY_VISIBILITY = true
export(PackedScene) var spot_scene

func _ready():
	$Trajectory.position = $LaunchPoint.position

func _process(delta):
	for spot in $Trajectory.get_children() :
		spot.queue_free()
	
	if Engine.is_editor_hint() and TRAJECTORY_VISIBILITY :
		draw_trajectory_for_impulse(Vector2(TRAJECTORY_IMPULSE * STRENGTH, 0).rotated(deg2rad( - TRAJECTORY_ANGLE)))
	else :
		update_elastic($ElasticBack)
		update_elastic($ElasticFront)
		var impulse = get_impulse()
		if is_instance_valid(self.bird) and self.bird.state == BirdScript.STATE_DRAGGED and impulse.x > 0 :
			draw_trajectory_for_impulse(impulse)
	
func update_elastic(elastic) :
	var attach_pos = self.bird.get_node("AttachPoint").get_global_position() if is_instance_valid(self.bird) else $LaunchPoint.get_global_position()
	var diff_pos = attach_pos - elastic.get_node("FixationPoint").get_global_position()
	var middle = diff_pos / 2
	var sprite = elastic.get_node("Sprite")
	sprite.position = middle
	sprite.scale.x = - middle.length() * 0.01
	sprite.rotation = middle.angle()
	
func attach_bird(bird) :
	self.bird = bird
	
func detach_bird() :
	self.bird = null
	
func get_impulse() :
	if ! is_instance_valid(self.bird) :
		return null
	
	return ($LaunchPoint.global_position - self.bird.global_position) * STRENGTH
	
func draw_trajectory_for_impulse(impulse) :
	var gravity = ProjectSettings.get("physics/2d/default_gravity")
	for i in range(0, TRAJECTORY_SPOT_COUNT) :
		var t = i * TRAJECTORY_TIME_STEP
		var x = impulse.x * t
		var y = gravity * t * t / 2 + impulse.y * t
		draw_spot(Vector2(x,y))
		
func draw_spot(position):
	var spot = spot_scene.instance()
	spot.position = position
	$Trajectory.add_child(spot)