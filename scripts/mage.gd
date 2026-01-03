class_name Mage extends CharacterBody2D

################################################################################

enum MageState {
	idle,
	run,
	attack,
	death
}

################################################################################

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var hurtbox: Area2D = $HurtArea

################################################################################

@export var speed: float = 2000.0
@export var attack_range: float = 200.0

################################################################################

var player: Player = null
var state: MageState = MageState.idle

################################################################################

func _process(delta: float) -> void:
	match state:
		MageState.idle: idle_state(delta)
		MageState.run: run_state(delta)
		MageState.attack: attack_state(delta)
		MageState.death: death_state(delta)

################################################################################

func idle_state(_delta: float) -> void:
	animation_tree.play_animation("idle")
	
	if not player:
		player = get_tree().get_first_node_in_group("player")
		
	if not player:
		return
		
	if check_attack_range():
		state = MageState.attack
	else:
		state = MageState.run
	
################################################################################

func run_state(delta: float) -> void:
	if not player:
		state = MageState.idle
		return
	
	if check_attack_range():
		state = MageState.attack
		return
		
	animation_tree.play_animation("run")
	
	velocity = global_position.direction_to(player.global_position).normalized() * speed * delta
	animation_tree.blend_position = velocity.normalized().x

	move_and_slide()
	
################################################################################

func attack_state(_delta: float) -> void:
	if not player:
		state = MageState.idle
		return
	
	if not check_attack_range():
		state = MageState.run
		return
		
	animation_tree.play_animation("attack")
	
################################################################################

func death_state(_delta: float) -> void:
	animation_tree.play_animation("death")
	
################################################################################

func check_attack_range() -> bool:
	if not player:
		return false
	
	if position.distance_to(player.position) <= attack_range:
		return true
		
	return false

################################################################################

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "death":
		queue_free()

func _on_hurt_area_entered(_area: Area2D) -> void:
	state = MageState.death
