class_name MagicBullet
extends Node2D

################################################################################

@onready var hurtbox: Area2D = $HurtBox
@onready var hitbox: Area2D = $HitBox

################################################################################

@export var speed: float = 75

################################################################################

var direction	: Vector2
var pushed: bool = false

################################################################################

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	
	if not player:
		queue_free()
		
	var target_position = player.global_position + Vector2(0.0, -10.0)
	direction = position.direction_to(target_position).normalized()

################################################################################

func _process(delta):
	position += direction * speed * Global.time_scale * delta

################################################################################

func _on_hurt_box_area_entered(area):
	if area.get_parent() == self:
		return

	if area.name == "Remover":
		queue_free()
		return
		
	if area.get_parent().is_in_group("characters") and not area.get_parent() is Player:
		queue_free()
		area.get_parent().queue_free()
		return

	if pushed:
		return
		
	hurtbox.set_collision_mask_value(3, false)
	hitbox.set_collision_layer_value(3, true)
	
	var player = get_tree().get_first_node_in_group("player")
		
	direction = Vector2(player.global_position.direction_to(global_position).x, 0).normalized()
	pushed = true
