class_name Slime extends CharacterBody2D

################################################################################

enum SlimeState {
	idle,
	jump,
	death
}

################################################################################

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer

################################################################################

@export var speed: float = 70.0
@export var drop: Resource

################################################################################

var player: Player = null
var state: SlimeState = SlimeState.idle
var direction: Vector2 = Vector2.ZERO
var is_dead: bool = false

################################################################################

func _process(delta: float) -> void:
	match state:
		SlimeState.idle: idle_state(delta)
		SlimeState.jump: jump_state(delta)
		SlimeState.death: death_state(delta)

################################################################################

func idle_state(_delta: float) -> void:
	animation_tree.play_animation("idle")
	
	if not player:
		player = get_tree().get_first_node_in_group("player")

	state = SlimeState.jump

################################################################################

func jump_state(delta: float) -> void:
	if not player:
		state = SlimeState.idle
		return
		
	animation_tree.play_animation("jump")
	
	direction = global_position.direction_to(player.global_position).normalized()
	velocity = direction * speed * Global.time_scale
	animation_tree.blend_position = velocity.normalized().x

	move_and_slide()
	
################################################################################

func death_state(_delta: float) -> void:
	animation_tree.play_animation("death")

################################################################################

func drop_slime():
	var spawn_here = get_tree().get_first_node_in_group("spawn_here")
	for i in range(randi_range(1, 5)):
		var offset := Vector2(randf_range(-20, 20),randf_range(-20, 20))
		var new_drop: SmallSlime = drop.instantiate()
		new_drop.global_position = global_position + offset
		spawn_here.add_child(new_drop)

################################################################################

func _on_hurt_area_entered(_area: Area2D) -> void:
	state = SlimeState.death

func _on_animation_tree_animation_finished(anim_name: StringName):
	if is_dead:
		return

	if anim_name.begins_with("death"):
		is_dead = true
		drop_slime()
		get_tree().get_first_node_in_group("root").score += 5
		queue_free()
