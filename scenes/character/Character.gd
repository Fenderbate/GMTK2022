extends KinematicBody


export(int)var health = 100
export(int)var damage = 10
export(Texture)var sprite
export(String, "Hero","Enemny", "All")var group = "All"
export(String, "Hero","Enemny", "All")var target_group = "All"
export(String, "Ranged", "Melee")var attack_type = "Melee"
export(int)var ranged_range = 100
export(int)var melee_range = 20
export(int)var speed = 10


var attack_range = 0

var target = null
var target_request_sent = false

var path_to_target = null

# Called when the node enters the scene tree for the first time.
func _ready():
	
	SignalManager.connect("send_target",self,"on_target_sent")
	SignalManager.connect("remove_from_target",self,"on_target_removed")
	SignalManager.connect("send_path",self,"on_path_sent")
	
	$Sprite3D.texture = sprite
	$Sprite3D.offset = Vector2(-sprite.get_size().x / 2, 0)
	
	add_to_group(group)
	
	attack_range = melee_range if attack_type == "Melee" else ranged_range
	



func _physics_process(delta):
	
	if target == null and !target_request_sent:
		
		SignalManager.emit_signal("request_target",self, target_group)
		
		target_request_sent = true
		
	elif target != null and path_to_target != null:
		
		for point in path_to_target:
			
			var dir = (point - transform.origin).normalized()
			
			move_and_slide(dir * speed, Vector3.UP)
			
		
		
	
	



func hurt(damage):
	
	health -= damage
	
	if health <= 0:
		print("add death anmination")
		SignalManager.emit_signal("remove_from_target",self)
		queue_free()
	

func on_target_sent(sender_node_instance_id, target_node):
	
	if sender_node_instance_id == get_instance_id():
	
		target = target_node
		
		target_request_sent = false
		
		SignalManager.emit_signal("request_path",self, target)
		
		$PathRequestTimer.start()
	

func on_target_removed(target_node):
	
	target = null
	
	$PathRequestTimer.stop()
	
	#SignalManager.emit_signal("request_target",transform.origin, "Enemy")
	

func on_path_sent(sender_node_instance_id, path):
	
	if sender_node_instance_id == get_instance_id():
		
		path_to_target = path
		
	



func _on_PathRequestTimer_timeout():
	if target != null:
		
		SignalManager.emit_signal("request_path",self, target)
		
