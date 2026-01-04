class_name Projectile
extends Node2D

################################################################################

@export var speed: float = 1000

################################################################################

var direction	: Vector2

################################################################################

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	
	if not player:
		queue_free()
		
	var target_position = player.global_position + Vector2(0.0, -8.0)
	direction = position.direction_to(target_position)
	look_at(target_position)

################################################################################

func _process(delta):
	position += direction * speed * delta

################################################################################

func _on_hit_box_area_entered(_area):
	queue_free()
