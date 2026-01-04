class_name Bomb extends CharacterBody2D

enum BombState {
	fuse,
	pushed,
	boom
}

################################################################################

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var hurt_area: Area2D = $HurtArea

################################################################################

@export var speed: float = 800.0
@export var push_distance: float = 200.0
 
################################################################################

var player: Player = null
var state: BombState = BombState.fuse
var start_position: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.ZERO

################################################################################

func _process(delta: float) -> void:
	match state:
		BombState.fuse: fuse_state(delta)
		BombState.pushed: pushed_state(delta)
		BombState.boom: boom_state(delta)

################################################################################

func fuse_state(_delta: float) -> void:
	animation_tree.play_animation("fuse")

################################################################################

func pushed_state(delta: float) -> void:
	animation_tree.play_animation("pushed")
	
	if global_position.distance_to(start_position) >= push_distance:
		velocity = Vector2.ZERO
		state = BombState.fuse
		return
	else:
		velocity = direction * speed * delta
	
	move_and_slide()

################################################################################

func boom_state(_delta: float) -> void:
	animation_tree.play_animation("boom")

################################################################################

func get_direction():
	player = get_tree().get_first_node_in_group("player")
	var player_position = player.global_position
	start_position = global_position
	direction = Vector2(start_position.x - player_position.x, 0).normalized()

################################################################################

func _on_hurt_area_entered(_area: Area2D) -> void:
	if state == BombState.boom:
		return

	get_direction()
	state = BombState.pushed

func _on_timer_timeout() -> void:
	state = BombState.boom

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "boom":
		queue_free()
