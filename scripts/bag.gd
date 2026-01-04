class_name Drop extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var drop_list: Array[Resource]

func _ready() -> void:
	animation_player.play("idle")

################################################################################

func drop_random():
	var drop_scene = drop_list.pick_random()
	var spawn_here = get_tree().get_first_node_in_group("spawn_here")
	var drop = drop_scene.instantiate()
	drop.global_position = global_position
	spawn_here.add_child(drop)

################################################################################

func _on_bonus_area_entered(area: Area2D) -> void:
	if area is PickupArea:
		queue_free()

func _on_hurt_area_entered(_area: Area2D) -> void:
	animation_player.play("open")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "open":
		drop_random()
		queue_free()
