extends Node


signal request_target(sender_node, target_tag)

signal send_target(sender_node_instance_id, target_node)

signal remove_from_target(target_node)


signal request_path(sender_node, target_node)

signal send_path(sender_node_instance_id, path)


signal attack(target_instance_id, damage)


signal throw_dice(target_node_instace_id)

signal send_dice_number(number, target_node_instace_id)


signal select_character(selected_character_instance_id)


signal select_die(die_instance_id)

signal upgrade_die(die_instance_id)

signal add_die()


signal gold_changed()


signal character_death(dead_node)

signal game_start()

signal game_won()

signal game_lost()
