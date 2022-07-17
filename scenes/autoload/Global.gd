extends Node


var gold = 0 setget set_gold

var rounds = {
	"Round1" : {"MeleGoblin" : 4},
	"Round2" : {"MeleGoblin" : 3, "RangedGoblin" : 2},
	"Round3" : {"Troll" : 1},
	"Round4" : {"RangedGoblin" : 2, "Troll" : 1},
	"Round5" : {"MeleGoblin" : 4, "Troll" : 2}
	
}


func _ready():
	
	SignalManager.connect("character_death",self,"on_character_died")
	SignalManager.connect("game_won",self,"on_game_won")
	SignalManager.connect("game_start",self,"on_game_start")
	
	get_tree().paused = true
	

func set_gold(new_value):
	
	gold = new_value if new_value >= 0 else 0
	
	SignalManager.emit_signal("gold_changed")


func on_character_died(dead_character):
	
	set_gold(gold + dead_character.loot)
	

func on_game_won():
	get_tree().paused = true

func on_game_start():
	$GameStartUI.hide()
	get_tree().paused = false


func _on_Button_button_down():
	SignalManager.emit_signal("game_start")
