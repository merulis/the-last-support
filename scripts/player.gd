class_name Player extends CharacterBody2D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var playback = animation_tree.get("parameters/StateMachine/playback") as AnimationNodeStateMachinePlayback

@onready var size_timer: Timer = $SizeTimer
@onready var time_timer: Timer = $TimeTimer
@onready var shield_timer: Timer = $ShieldTimer
@onready var speed_timer: Timer = $SpeedTimer
@onready var hurtbox_area: Area2D = $HurtboxArea
@onready var attack_audio_player = $AttackAudioPlayer
@onready var death_audio_player = $DeathAudioPlayer
@onready var bonus_audio_player = $BonusAudioPlayer

@export var bonus_duration: float = 10.0
@export var bonus_size_scale: float = 1.7
@export var bonus_speed_scale: float = 3.0
@export var bonus_time_scale: float = 0.3

@export var SPEED: float = 5000

signal dead()

enum PlayerState {
	idle,
	run,
	attack,
	death
}

var input_vector: = Vector2.ZERO
var last_input_vector: = Vector2.RIGHT

var state: PlayerState = PlayerState.idle
var speed: float = SPEED

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
		attack_audio_player.play()
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
		attack_audio_player.play()
		state = PlayerState.attack
		
	velocity = input_vector * speed * delta
	move_and_slide()

################################################################################

func attack_state(_delta: float) -> void:
	animation_tree.play_animation("attack")

################################################################################

func death_state(_delta: float) -> void:
	animation_tree.play_animation("death")

################################################################################

func apply_bonus(bonus_name):
	bonus_audio_player.play()
	match bonus_name:
		"size": 
			start_timer(size_timer, bonus_duration)
			apply_size_bonus()
		"speed":
			start_timer(speed_timer, bonus_duration)
			apply_speed_bonus()
		"shield":
			start_timer(shield_timer, bonus_duration)
			apply_shield_bonus()
		"time":
			start_timer(time_timer, bonus_time_scale*bonus_duration)
			apply_time_bonus()

func start_timer(timer: Timer, duration: float):
	timer.start(duration)

func apply_size_bonus():
	reset_size_bonus()
	scale *= bonus_size_scale

func reset_size_bonus():
	scale = Vector2(1,1)

func apply_speed_bonus():
	reset_speed_bonus()
	speed *= bonus_speed_scale

func reset_speed_bonus():
	speed = SPEED
	
func apply_shield_bonus():
	hurtbox_area.monitoring = false
	
func reset_shield_bonus():
	hurtbox_area.monitoring = true
	
func apply_time_bonus():
	for c in get_tree().get_nodes_in_group("characters"):
		if c != self and "time_scale" in c:
			print(c.name)
			c.time_scale = bonus_time_scale
	
func reset_time_bonus():
	for c in get_tree().get_nodes_in_group("characters"):
		if c != self and "time_scale" in c:
			c.time_scale = 1.0

func _on_size_timer_timeout() -> void:
	reset_size_bonus()

func _on_speed_timer_timeout() -> void:
	reset_speed_bonus()

func _on_shield_timer_timeout() -> void:
	reset_shield_bonus()

func _on_time_timer_timeout() -> void:
	reset_time_bonus()

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
		if not death_audio_player.playing:
			death_audio_player.play()
		state = PlayerState.death
	if area.get_parent() is MagicBullet:
		area.get_parent().queue_free()

func _on_pickup_area_entered(area: Area2D) -> void:
	print("Player pickup area entered: ",area.name)
	if area is BonusArea:
		apply_bonus(area.bonus_type)
