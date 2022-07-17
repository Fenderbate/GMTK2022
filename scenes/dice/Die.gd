extends RigidBody


var thrown = false

var collided = false

var number = -1

var target_instance_id

var number_sent = false

var selected = false

# Called when the node enters the scene tree for the first time.
func _ready():
	
	randomize()
	
	connect("body_entered",self,"_on_die_body_entered")
	connect("input_event",self,"_on_die_input_event")
	SignalManager.connect("select_die",self,"on_die_selected")
	
	linear_velocity = 0.7 * Vector3.DOWN
	
	angular_velocity = Vector3(rand_range(-1,1), rand_range(-1,1), rand_range(-1,1))
	
	$Mesh.material_override = load("res://assets/3d assets/DiceMaterial.tres").duplicate(true)


func _physics_process(delta):
	
	if linear_velocity.length() < 0.5 and collided:
		
		if has_node("NumberDisplay"):
			
			$NumberDisplay/Viewport/Bubble/Number.text = str(number)
			$NumberDisplay.show()
			$NumberDisplay/Sprite3D.show()
			$NumberDisplay/Viewport.update_worlds()
			
			$NumberDisplay/Sprite3D.texture = $NumberDisplay/Viewport.get_texture()
			
			if !number_sent:
				SignalManager.emit_signal("send_dice_number",number,target_instance_id)
				number_sent = true
			
	
	
	
func reset():
	collided = false
	number_sent = false
	#if has_node("NumberDisplay"):
	$NumberDisplay.hide()
	$NumberDisplay/Sprite3D.hide()
	

func _on_die_body_entered(body):
	
	if collided:
		return
	
	if body.is_in_group("Box"):
		
		SignalManager.emit_signal("die_landed")
		
		collided = true
	
	number = 0
		
	var group = get_groups()[0]
	
	match group:
		"D4":
			number = randi() % 4
		"D6":
			number = randi() % 6
		"D8":
			number = randi() % 8
		"D10":
			number = randi() % 10
		"D12":
			number = randi() % 12
		"D20":
			number = randi() % 20
	
	number += 1
	
func _on_die_input_event(camera, event, position, normal, shape_idx):
	
	if get_groups()[0] == "D20":
		return
	
	if event is InputEventMouseButton and event.pressed:
		
		print("Die clicked!")
		
		SignalManager.emit_signal("select_die",get_instance_id())
		
		pass

func on_die_selected(instance_id):
	
	selected = true if instance_id == get_instance_id() else false
	
	if selected:
		
		print("selected!!!")
		
		$Mesh.material_override.set("flags_unshaded",true)
	else:
		$Mesh.material_override.set("flags_unshaded",false)
	
		
	
