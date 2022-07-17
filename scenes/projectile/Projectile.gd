extends Spatial

export(Curve)var shooting_arch_curve
export(float)var projectile_speed = 1
export(Texture)var sprite
export(int)var damage = 10
export(float)var target_distance_bias = 3

var sender_node : Spatial = null
var target_node : Spatial = null

var shooting_arch_curve_index = 0

var shot = false

# Called when the node enters the scene tree for the first time.
func _ready():
	
	$Sprite3D.texture = sprite


func _physics_process(delta):
	
	
	$Sprite3D.transform.origin.y = 3 * shooting_arch_curve.interpolate(shooting_arch_curve_index)
	
	if target_node != null:
		if transform.origin.distance_to(target_node.transform.origin) < target_distance_bias:
			$Tween.stop_all()
			SignalManager.emit_signal("attack",target_node.get_instance_id(), damage)
			queue_free()
	


func shoot():
	$Tween.interpolate_property(
		self,
		"translation",
		Vector3(sender_node.transform.origin.x,2,sender_node.transform.origin.z),
		Vector3(target_node.transform.origin.x,2,target_node.transform.origin.z),
		projectile_speed
	)
	
	$Tween.interpolate_property(
		self,
		"shooting_arch_curve_index",
		0,
		1,
		projectile_speed
	)
	
	$Tween.start()
	
	shot = true


func _on_Tween_tween_all_completed():
	
	SignalManager.emit_signal("attack",target_node.get_instance_id(), damage)
	
	queue_free()
	
