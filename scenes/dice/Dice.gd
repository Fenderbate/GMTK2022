extends Spatial


var throw_cooldown = 0

var max_throw_cooldown = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	
	SignalManager.connect("throw_dice",self,"throw_dice")
	SignalManager.connect("upgrade_die",self,"on_die_upgrade")
	SignalManager.connect("add_die",self,"on_die_added")
	
	for time in 3:
		add_die($D4)
	
	max_throw_cooldown = check_cooldown()
	
	

func _physics_process(delta):
	
	throw_cooldown = throw_cooldown - delta if throw_cooldown > 0 else 0
	
	


	

func add_die(die_to_add):
	
	var die = die_to_add.duplicate()
	
	die.global_transform.origin = $ThrowingPos.global_transform.origin
	
	die.show()
	
	die.mode = RigidBody.MODE_RIGID
	
	
	var display = $NumberDisplay.duplicate()
	
	display.global_transform.origin = Vector3()
	
	die.add_child(display)
	
	die.thrown = true
	
	$ThrowingDice.add_child(die)
	
	
	

func throw_dice(sender_instance_id):
	
	var dice = $ThrowingDice.get_children()
	
	for die in dice:
		
		die.reset()
		
		die.angular_velocity = Vector3(rand_range(-0.5,0.5),rand_range(-1,1),rand_range(-1,1))
		
		die.global_transform.origin = $ThrowingPos.global_transform.origin + Vector3(rand_range(-1,1), 0, rand_range(-1,1))
		
		die.target_instance_id = sender_instance_id
		
		max_throw_cooldown = check_cooldown()
		
		throw_cooldown = max_throw_cooldown
	

func check_cooldown():
	
	var dice = $ThrowingDice.get_children()
	
	var cooldown = 0
	
	for die in dice:
	
		var group = die.get_groups()[0]
		
		match group:
			"D4":
				cooldown += 1
			"D6":
				cooldown += 2
			"D8":
				cooldown += 3
			"D10":
				cooldown += 3
			"D12":
				cooldown += 4
			"D20":
				cooldown += 4
	
	return cooldown
	

func get_throw_cooldown():
	
	return float(throw_cooldown * 1.0) / float(max_throw_cooldown * 1.0)
	

func on_die_upgrade(die_instance_id):
	
	var selected_die_group = null
	
	for die in $ThrowingDice.get_children():
		if die.get_instance_id() == die_instance_id:
			
			selected_die_group = die.get_groups()[0]
			die.queue_free()
			print("Do die upgrade anim?")
			
	
	match selected_die_group:
			"D4":
				add_die($D6)
			"D6":
				add_die($D8)
			"D8":
				add_die($D10)
			"D10":
				add_die($D12)
			"D12":
				add_die($D20)
			"D20":
				pass
	

func on_die_added():
	add_die($D4)
