extends Node


var gold = 0 setget set_gold


func set_gold(new_value):
	
	gold = new_value if new_value >= 0 else 0
	
	SignalManager.emit_signal("gold_changed")
