class_name Bonus extends CharacterBody2D

func _on_bonus_area_entered(area: Area2D) -> void:
	if area is PickupArea:
		queue_free()
