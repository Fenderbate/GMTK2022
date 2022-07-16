extends Navigation


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.connect("request_path",self,"on_path_requested")
	SignalManager.connect("request_target",self,"on_target_requested")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func on_target_requested(sender_node : Spatial, target_tag : String):
	
	var target_array = get_tree().get_nodes_in_group(target_tag)
	var selected_target = null
	var selected_distance = 1000000
	
	for target in target_array:
		
		if sender_node.transform.origin.distance_to(target.transform.origin) < selected_distance:
			selected_distance = sender_node.transform.origin.distance_to(target.transform.origin)
			selected_target = target
		
	
	SignalManager.emit_signal("send_target", sender_node.get_instance_id(), selected_target)
	

func on_path_requested(sender_node : Node, target_node : Node):
	
	print("requested path from: ", sender_node.name," to: ",target_node.name)
	
	var path = get_simple_path(sender_node.transform.origin, target_node.transform.origin)
	
	SignalManager.emit_signal("send_path",sender_node.get_instance_id(),path)
	
