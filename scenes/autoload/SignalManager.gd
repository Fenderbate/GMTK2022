extends Node


signal request_target(sender_node, target_tag)

signal send_target(sender_node_instance_id, target_node)

signal remove_from_target(target_node)


signal request_path(sender_node, target_node)

signal send_path(sender_node_instance_id, path)


signal attack(target, damage)


signal throw_dice(target_node_instace_id)

signal send_dice_number(number, target_node_instace_id)


signal select_character(selected_character_instance_id)
