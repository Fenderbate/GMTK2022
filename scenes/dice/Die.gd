extends RigidBody


var thrown = false


# Called when the node enters the scene tree for the first time.
func _ready():
	linear_velocity = 0.7 * Vector3.DOWN


func _physics_process(delta):

	if thrown:
		print(linear_velocity.length())
	
	if linear_velocity.length() < 0.5:
		
		if has_node("NumberDisplay"):
			
			$NumberDisplay/Viewport/Bubble/Number.text = "69"
			$NumberDisplay.show()
		
	
