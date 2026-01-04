class_name Projectile
extends Node2D

################################################################################

@onready var hurtbox: Area2D = $HurtBox
@onready var hitbox: Area2D = $HitBox

################################################################################

@export var speed: float = 1000

################################################################################

var direction	: Vector2

################################################################################

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	
	if not player:
		queue_free()
		
	var target_position = player.global_position + Vector2(0.0, -10.0)
	direction = position.direction_to(target_position).normalized()

################################################################################

func _process(delta):
	position += direction * speed * delta

################################################################################

func _on_hurt_box_area_entered(area):
	if area.name == "Remover":
		queue_free()

	var player = get_tree().get_first_node_in_group("player")
	
	if not player:
		queue_free()
		
	direction = Vector2(player.global_position.direction_to(global_position).x, 0).normalized()
	hitbox.set_collision_layer_value(3, true)
	hitbox.set_collision_mask_value(3, false)

################################################################################

func _on_hit_box_area_entered(area):
	var parent = area.get_parent()
	print(parent.name)
	print(parent.is_in_group("player"))
	if not parent.is_in_group("player"):
		queue_free()
