extends Camera

export(int)var mouse_bias = 10
export(int)var cam_speed = 20

var dir = Vector3()

var viewport

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	
	viewport = get_viewport()


func _process(delta):
	
	var mouse_pos = viewport.get_mouse_position()
	
	if mouse_pos.x < mouse_bias:
		
		transform.origin += Vector3(-cam_speed,0,cam_speed)*delta
		
	if mouse_pos.y < mouse_bias:
		
		transform.origin += Vector3(-cam_speed,0,-cam_speed)*delta
	
	if mouse_pos.x > viewport.get_visible_rect().size.x - mouse_bias:
		
		transform.origin += Vector3(cam_speed,0,-cam_speed)*delta
	
	if mouse_pos.y > viewport.get_visible_rect().size.y - mouse_bias:
		
		transform.origin += Vector3(cam_speed,0,cam_speed)*delta
	
