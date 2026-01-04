extends CharacterBody2D

func _on_bonus_area_entered(area: Area2D) -> void:
	print("Bonus area entered: ", area.name)
	if area is PickupArea:
		queue_free()
