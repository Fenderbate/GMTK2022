extends Navigation


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var selected_character_instance_id = null setget set_selected_char
func set_selected_char(new_value):
	
	print(new_value)
	
	if new_value == selected_character_instance_id:
		selected_character_instance_id = null
	
	selected_character_instance_id = new_value

var selected_die_id = null

var enemy_count = 0

var round_index = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.connect("request_path",self,"on_path_requested")
	SignalManager.connect("request_target",self,"on_target_requested")
	SignalManager.connect("select_character",self,"on_character_selected")
	SignalManager.connect("select_die",self,"on_die_selected")
	SignalManager.connect("gold_changed",self,"on_gold_changed")
	SignalManager.connect("character_death",self,"on_character_died")
	
	spawn_enemies()
	

func _physics_process(delta):
	
	#$Control/DiceCam.texture = $Control/DiceViewport.get_texture()
	
	$Control/ThrowCooldown.value = $Control/ViewportContainer/DiceViewport/Dice.get_throw_cooldown()
	
	if $Control/ViewportContainer/DiceViewport/Dice.get_throw_cooldown() <= 0 and selected_character_instance_id != null:
		$Control/ThrowButton.disabled = false
	else:
		$Control/ThrowButton.disabled = true
	

func _input(event):
	
	if event.is_action_pressed("ui_accept") and selected_character_instance_id != null:
		
		SignalManager.emit_signal("throw_dice",selected_character_instance_id)
		
		set_selected_char(null)

func on_target_requested(sender_node : Spatial, target_tag : String):
	
	var target_array = get_tree().get_nodes_in_group(target_tag)
	var selected_target = null
	var selected_distance = 1000000
	
	for target in target_array:
		
		if target.active and sender_node.transform.origin.distance_to(target.transform.origin) < selected_distance:
			selected_distance = sender_node.transform.origin.distance_to(target.transform.origin)
			selected_target = target
		
	
	if selected_target == null:
		print("Couldn't find new valid target for: ",sender_node.name)
		return
	
	SignalManager.emit_signal("send_target", sender_node.get_instance_id(), selected_target)
	

func spawn_enemies():
	
	if round_index >= Global.rounds.size():
		SignalManager.emit_signal("game_won")
	
	var enemies : Dictionary = Global.rounds[str("Round",round_index)]
	
	for enemy in enemies.keys():
		
		for count in enemies[enemy]:
		
			var enemy_to_spawn : Spatial = load(str("res://prefabs/",enemy,".tscn")).instance()
			
			enemy_to_spawn.transform.origin = $SpawnPosition.get_children()[randi() % $SpawnPosition.get_child_count()].transform.origin + Vector3(rand_range(-1,1), 0, rand_range(-1,1))
			
			#enemy_to_spawn.active = false
			
			add_child(enemy_to_spawn)
			
			enemy_count += 1
	
	pass
	

func on_path_requested(sender_node : Node, target_node : Node):
	
	var path = get_simple_path(sender_node.transform.origin, target_node.transform.origin)
	
	SignalManager.emit_signal("send_path",sender_node.get_instance_id(),path)
	

func on_character_selected(instance_id):
	
	set_selected_char(instance_id)


func _on_Throw_button_down():
	SignalManager.emit_signal("throw_dice",selected_character_instance_id)
		
	#set_selected_char(null)
	
	$Control/UpgradeButton.hide()

func on_die_selected(die_instance_id):
	
	selected_die_id = die_instance_id
	
	$Control/UpgradeButton.show()
	


func _on_UpgradeButton_button_down():
	
	if Global.gold < 10:
		return
	
	SignalManager.emit_signal("upgrade_die",selected_die_id)
	$Control/UpgradeButton.hide()
	Global.gold -= 10


func _on_Button_button_down():
	
	if Global.gold < 20:
		return
	SignalManager.emit_signal("add_die")
	Global.gold -= 20

func on_gold_changed():
	$Control/GoldLabel.text = str(Global.gold)

func on_character_died(dead_node):
	
	if dead_node.group == "Enemny":
		enemy_count -= 1
	
	if enemy_count == 0:
		#yield(get_tree().create_timer(2),"timeout")
		
		print("SPAWNING ENEMIES")
		
		round_index += 1
		spawn_enemies()
	
	pass
