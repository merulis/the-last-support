class_name Drop extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var drop_list: Array[Resource]
@export var drop_weights: Array[int]

################################################################################

func pick_weighted_drop_smooth(max_id: int) -> int:
	var total := 0
	var weights := []

	for i in range(max_id):
		var w = drop_weights[i]
		weights.append(w)
		total += w

	var roll = randi_range(1, total)
	var acc := 0

	for i in range(max_id):
		acc += weights[i]
		if roll <= acc:
			return i

	return 0
	
################################################################################

func _ready() -> void:
	animation_player.play("idle")

################################################################################

func drop_random():
	var spawn_here = get_tree().get_first_node_in_group("spawn_here")
	var new_drop = drop_list[pick_weighted_drop_smooth(7)].instantiate()
	new_drop.global_position = global_position
	spawn_here.add_child(new_drop)
	
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
