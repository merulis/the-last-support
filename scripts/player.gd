class_name Player extends CharacterBody2D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree.get("parameters/StateMachine/playback") as AnimationNodeStateMachinePlayback

signal dead()

enum PlayerState {
	idle,
	run,
	attack,
	death
}

const SPEED = 100.0

var input_vector: = Vector2.ZERO
var last_input_vector: = Vector2.RIGHT

var state: PlayerState = PlayerState.idle

################################################################################

func _process(delta: float) -> void:
	match state:
		PlayerState.idle: idle_state(delta)
		PlayerState.run: run_state(delta)
		PlayerState.attack: attack_state(delta)
		PlayerState.death: death_state(delta)

################################################################################

func idle_state(_delta: float) -> void:
	animation_tree.play_animation("idle")
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	if input_vector.length() > 0.0:
		state = PlayerState.run

	if Input.is_action_just_pressed("attack"):
		state = PlayerState.attack

################################################################################

func run_state(_delta: float) -> void:
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
			
	if input_vector != Vector2.ZERO:
		last_input_vector = input_vector
		animation_tree.play_animation("run")
		var direction_vector: = Vector2(input_vector.x, -input_vector.y).normalized()
		animation_tree.blend_position = direction_vector.x
	else:
		state = PlayerState.idle

	if Input.is_action_just_pressed("attack"):
		state = PlayerState.attack
	
	velocity = input_vector * SPEED
	move_and_slide()

################################################################################

func attack_state(_delta: float) -> void:
	animation_tree.play_animation("attack")

################################################################################

func death_state(_delta: float) -> void:
	animation_tree.play_animation("death")
	dead.emit()

################################################################################

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name.begins_with("attack"):
		state = PlayerState.idle

func _on_hurtbox_area_area_entered(_area: Area2D) -> void:
	state = PlayerState.death
