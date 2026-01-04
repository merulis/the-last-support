class_name Player extends CharacterBody2D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree.get("parameters/StateMachine/playback") as AnimationNodeStateMachinePlayback

@onready var size_timer: Timer = $SizeTimer

@export var bonus_increase_scale: float = 1.7

signal dead()

enum PlayerState {
	idle,
	run,
	attack,
	death
}

@export var SPEED = 100.0

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
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	if input_vector.length() > 0.0:
		state = PlayerState.run

	if Input.is_action_just_pressed("attack"):
		state = PlayerState.attack
		
	animation_tree.play_animation("idle")

################################################################################

func run_state(delta: float) -> void:
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
	
	velocity = input_vector * SPEED * delta
	move_and_slide()

################################################################################

func attack_state(_delta: float) -> void:
	animation_tree.play_animation("attack")

################################################################################

func death_state(_delta: float) -> void:
	animation_tree.play_animation("death")

################################################################################

func apply_bonus(bonus_name):
	match bonus_name:
		"size": 
			start_timer(size_timer)
			apply_size_bonus()

func start_timer(timer: Timer):
	timer.start()

func apply_size_bonus():
	reset_size_bonus()
	scale *= bonus_increase_scale

func reset_size_bonus():
	scale = Vector2(1,1)

func _on_size_timer_timeout() -> void:
	reset_size_bonus()

################################################################################

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name.begins_with("attack"):
		state = PlayerState.idle
	elif anim_name.begins_with("death"):
		dead.emit()

################################################################################

func _on_hurt_area_entered(area: Area2D) -> void:
	print("Player hurt area entered: ",area.name)
	if area.name.begins_with("Hit"):
		state = PlayerState.death
		
func _on_pickup_area_entered(area: Area2D) -> void:
	print("Player pickup area entered: ",area.name)
	if area is BonusArea:
		apply_bonus(area.bonus_type)
