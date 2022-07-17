tool
extends KinematicBody


export(bool)var active = true
export(int)var health = 100
export(int)var damage = 10
export(Texture)var sprite setget set_sprite
export(String, "Hero","Enemny", "All")var group = "All"
export(String, "Hero","Enemny", "All")var target_group = "All"
export(String, "Ranged", "Melee")var attack_type = "Melee"
export(int)var attack_range = 100
export(int)var speed = 10
export(float)var attack_speed = 1.0
export(Curve)var attack_anim_curve
export(int)var loot = 0
export(Color)var healthbar_color = Color("9dff00") setget set_healthbar_color
export(Color)var selected_color = Color("ffffff")

var attack_timer = attack_speed

var target = null
var target_request_sent = false

var path_to_target : Array = []

var currect_path_target = Vector3()
var path_distance_bias = 1
var dir = Vector3()
var side_dir = 0

var attack_anim_curve_index = 0

var attacking = false

var selected = false

func set_sprite(new_sprite):
	
	sprite = new_sprite
	
	if Engine.editor_hint:
		$Sprite3D.texture = sprite
		$Sprite3D.offset = Vector2(-sprite.get_size().x / 2, 0)
		
		$HealthSprite.offset = Vector2(0, sprite.get_size().y / 2 + 20)
		

func set_healthbar_color(new_color):
	
	healthbar_color = new_color
	


# Called when the node enters the scene tree for the first time.
func _ready():
	
	SignalManager.connect("send_target",self,"on_target_sent")
	SignalManager.connect("remove_from_target",self,"on_target_removed")
	SignalManager.connect("send_path",self,"on_path_sent")
	SignalManager.connect("attack",self,"on_attacked")
	SignalManager.connect("send_dice_number",self,"on_dice_number_sent")
	SignalManager.connect("select_character",self,"on_character_selected")
	
	$Sprite3D.texture = sprite
	$Sprite3D.offset = Vector2(-sprite.get_size().x / 2, 0)
	
	$HealthSprite.offset = Vector2(0, sprite.get_size().y / 2 + 20)
	
	add_to_group(group)
	
	if group == "Enemny":
		$ClickArea/CollisionShape.disabled = true
	



func _physics_process(delta):
	if Engine.editor_hint:
		return
	
	$HealthSprite.texture = $HealthSprite/Viewport.get_texture()
	
	if !active:
		return
	
	$Sprite3D.transform.origin = dir * attack_anim_curve.interpolate(attack_anim_curve_index)
	
	if (target == null or !target.active) and !target_request_sent:
		
		SignalManager.emit_signal("request_target",self, target_group)
		
		target_request_sent = true
		
	elif target != null:
		
		target_request_sent = false
		
		if transform.origin.distance_to(target.transform.origin) > attack_range:
			
			if attacking: return
			
			if transform.origin.distance_to(currect_path_target) <= path_distance_bias and path_to_target.size() > 0:
				path_to_target.remove(0)
				currect_path_target = path_to_target[0] if path_to_target.size() > 0 else Vector3()
			
			dir = (currect_path_target - transform.origin).normalized()
			side_dir = -1 if dir.x > 0 else 1
			
			if $Animations/AnimationPlayer.current_animation != "walk":
				$Animations/AnimationPlayer.play("walk")
				$Sprite3D.flip_h = true if side_dir > 0 else false
			
			
			
			move_and_slide(dir * speed, Vector3.UP)
		
		else:
			
			if $Animations/AnimationPlayer.current_animation == "walk":
				$Animations/AnimationPlayer.play("RESET")
			
			attack_timer -= delta
			
			if attack_timer < 0:
				if attack_type == "Melee":
					SignalManager.emit_signal("attack",target.get_instance_id(),damage)
				elif attack_type == "Ranged":
					shoot_projectile(target)
				attack_timer = attack_speed
				$Animations/AttackTween.interpolate_property(self,"attack_anim_curve_index",0,1,0.25)
				$Animations/AttackTween.start()
				attacking = true
			
		

func shoot_projectile(shooting_target):
	
	var proj = $Projectile.duplicate()
	
	proj.transform.origin = transform.origin
	proj.sender_node = self
	proj.target_node = shooting_target
	
	proj.show()
	
	get_parent().add_child(proj)
	
	proj.shoot()
	
	pass


func on_attacked(target_instance_id, damage):
	
	if target_instance_id != get_instance_id() or !active:
		return
	
	health -= damage
	
	$HitSounds.get_children()[randi() % $HitSounds.get_child_count()].play()
	
	if health <= 0:
		print("add death anmination")
		active = false
		remove_from_group(group)
		SignalManager.emit_signal("remove_from_target",self)
		SignalManager.emit_signal("character_death",self)
		hide()
		
		if group == "Enemny":
			$GoblinDeath.get_children()[randi() % $GoblinDeath.get_child_count()].play()
		
		yield(get_tree().create_timer(1.5),"timeout")
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
	
	#if path.size() <= 0:
	#	SignalManager.emit_signal("request_target",self, target_group)
	
	if sender_node_instance_id == get_instance_id():
		
		path_to_target = path
		
		if path_to_target.size() > 0:
			currect_path_target = path_to_target[0]
		
	



func _on_PathRequestTimer_timeout():
	if target != null:
		
		SignalManager.emit_signal("request_path",self, target)
		


func _on_AttackTween_tween_completed(object, key):
	
	attacking = false

func on_dice_number_sent(number, instance_id):
	
	if instance_id != get_instance_id():
		return
	
	health += number
	
	print("IMPLEMENT DICE BUFFS! -on_dice_number_sent-")
	



func _on_input_event(camera, event, position, normal, shape_idx):
	if group != "Hero":
		return
	if event is InputEventMouseButton and event.pressed:
		SignalManager.emit_signal("select_character",get_instance_id())
		selected = !selected
		$Sprite3D.modulate = selected_color if selected else Color("ffffff")
		$Sprite3D.shaded = !selected
		

func on_character_selected(instance_id):
	if instance_id != get_instance_id():
		selected = false
		$Sprite3D.modulate = Color("ffffff")
		$Sprite3D.shaded = true
	else:
		$Sprite3D.shaded = false
	
	


