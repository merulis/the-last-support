class_name TheLastSupport extends CharacterBody2D

signal destroy()

func _on_hurt_area_entered(_area: Area2D) -> void:
	destroy.emit()
