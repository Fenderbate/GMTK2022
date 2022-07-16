extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	
	for time in 3:
		add_die()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	
	if event.is_action_pressed("ui_accept"):
		
		throw_dice()
		
		
	

func add_die():
	
	var die = $D4.duplicate()
	
	die.transform.origin = $ThrowingPos.transform.origin
	
	die.show()
	
	die.mode = RigidBody.MODE_RIGID
	
	
	var display = $NumberDisplay.duplicate()
	
	display.transform.origin = Vector3()
	
	die.add_child(display)
	
	die.thrown = true
	
	$ThrowingDice.add_child(die)
	
	
	

func throw_dice():
	
	var dice = $ThrowingDice.get_children()
	
	for die in dice:
		
		die.angular_velocity = Vector3(rand_range(-1,1),rand_range(-1,1),rand_range(-1,1))
		
		die.transform.origin = $ThrowingPos.transform.origin + Vector3(rand_range(-1,1), 0, rand_range(-1,1))
		
	
	pass
