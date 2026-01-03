class_name GoblinThief
extends CharacterBody2D

################################################################################

enum GoblinThiefState {
	idle,
	run,
	attack,
	death
}

################################################################################

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var hurtbox: Area2D = $Hurtbox

################################################################################

@export var speed: float = 2000.0
@export var attack_range: float = 25.0

################################################################################

var player: Player = null
var state: GoblinThiefState = GoblinThiefState.idle

################################################################################

func _process(delta: float) -> void:
	match state:
		GoblinThiefState.idle: idle_state(delta)
		GoblinThiefState.run: run_state(delta)
		GoblinThiefState.attack: attack_state(delta)
		GoblinThiefState.death: death_state(delta)

################################################################################

func idle_state(_delta: float) -> void:
	animation_tree.play_animation("idle")
	
	if not player:
		player = get_tree().get_first_node_in_group("player")
		
	if not player:
		return
		
	if check_atack_range():
		state = GoblinThiefState.attack
	else:
		state = GoblinThiefState.run
	
################################################################################

func run_state(delta: float) -> void:
	if not player:
		state = GoblinThiefState.idle
		return
	
	if check_atack_range():
		state = GoblinThiefState.attack
		return
		
	animation_tree.play_animation("run")
	
	velocity = global_position.direction_to(player.global_position).normalized() * speed * delta
	animation_tree.blend_position = velocity.normalized().x

	move_and_slide()
	
################################################################################

func attack_state(_delta: float) -> void:
	if not player:
		state = GoblinThiefState.idle
		return
	
	if not check_atack_range():
		state = GoblinThiefState.run
		return
		
	animation_tree.play_animation("attack")
	
################################################################################

func death_state(_delta: float) -> void:
	animation_tree.play_animation("death")
	
################################################################################

func check_atack_range() -> bool:
	if not player:
		return false
	
	if position.distance_to(player.position) <= attack_range:
		return true
		
	return false

################################################################################

func _on_hurtbox_area_entered(_area):
	state = GoblinThiefState.death

################################################################################

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "death":
		queue_free()
