extends Node2D


func _on_player_dead() -> void:
	_stop_game()


func _stop_game():
	var objects = get_tree().get_nodes_in_group("characters")
  
	for obj in objects:
		obj.set_process_mode(Node.PROCESS_MODE_DISABLED)
