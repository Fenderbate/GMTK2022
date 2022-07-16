tool
extends Node2D


export(NodePath)var character


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	
	update()
	

func _draw():
	
	draw_rect(Rect2(Vector2(-get_node(character).health / 2,-10), Vector2(get_node(character).health, 20)), get_node(character).healthbar_color)
	
