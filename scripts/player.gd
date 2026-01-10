class_name Player extends CharacterBody2D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var playback = animation_tree.get("parameters/StateMachine/playback") as AnimationNodeStateMachinePlayback

@onready var color_timer: Timer = $ColorTimer
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
@export var bonus_speed_value: float = 150
@export var bonus_time_scale: float = 0.5

var default_speed: float = 100
var speed: float = default_speed
var mob_web

signal dead()
signal bonus_gain(id: int)

enum PlayerState {
	idle,
	run,
	attack,
	death
}

enum Bonuses {
	speed,
	size,
	time,
	shield
}

const BONUS_COLORS := {
	Bonuses.speed: Color(1.25, 0.6, 0.6, 1.0),
	Bonuses.size: Color(1.25, 1.25, 0.75),
	Bonuses.time: Color(0.75, 0.85, 1.3),
	Bonuses.shield: Color(0.75, 0.78, 0.82),
}

var input_vector: = Vector2.ZERO
var last_input_vector: = Vector2.LEFT

var state: PlayerState = PlayerState.idle

################################################################################

func _ready():
	if is_mobile_web():
		var events = InputMap.action_get_events("attack")
		for e in events:
			InputMap.action_erase_event("attack", e)

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
	
	if input_vector.x != 0:
		last_input_vector.x = sign(input_vector.x)
	
	if input_vector.length() > 0.0:
		state = PlayerState.run

	if Input.is_action_just_pressed("attack"):
		attack_audio_player.play()
		state = PlayerState.attack

	animation_tree.play_animation("idle")

################################################################################

func run_state(_delta: float) -> void:
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	
	if input_vector.x != 0:
		last_input_vector.x = sign(input_vector.x)
		
	if input_vector != Vector2.ZERO:
		animation_tree.play_animation("run")
		animation_tree.blend_position = last_input_vector.x
	else:
		state = PlayerState.idle

	if Input.is_action_just_pressed("attack"):
		attack_audio_player.play()
		state = PlayerState.attack
		
	velocity = input_vector * speed
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
			apply_size_bonus()
			bonus_gain.emit(0)
		"speed":
			apply_speed_bonus()
			bonus_gain.emit(1)
		"shield":
			apply_shield_bonus()
			bonus_gain.emit(2)
		"time":
			apply_time_bonus()
			bonus_gain.emit(3)
	
	start_timer(color_timer)

func start_timer(timer: Timer):
	timer.start()

func apply_size_bonus():
	scale = Vector2(bonus_size_scale, bonus_size_scale)
	modulate = BONUS_COLORS[Bonuses.size]
	
	start_timer(size_timer)

func reset_size_bonus():
	scale = Vector2(1,1)

func apply_speed_bonus():
	speed = bonus_speed_value
	modulate = BONUS_COLORS[Bonuses.speed]
	start_timer(speed_timer)

func reset_speed_bonus():
	speed = 100

func apply_shield_bonus():
	hurtbox_area.monitoring = false
	modulate = BONUS_COLORS[Bonuses.shield]
	
	start_timer(shield_timer)

func reset_shield_bonus():
	hurtbox_area.monitoring = true

func apply_time_bonus():
	Global.time_scale = bonus_time_scale
	modulate = BONUS_COLORS[Bonuses.time]
	
	start_timer(time_timer)
	
func reset_time_bonus():
	Global.time_scale = 1.0

func _on_size_timer_timeout() -> void:
	reset_size_bonus()

func _on_speed_timer_timeout() -> void:
	reset_speed_bonus()

func _on_shield_timer_timeout() -> void:
	reset_shield_bonus()

func _on_time_timer_timeout() -> void:
	reset_time_bonus()
	
func _on_color_timer_timeout() -> void:
	modulate = Color.WHITE

################################################################################

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name.begins_with("attack"):
		state = PlayerState.idle
	elif anim_name.begins_with("death"):
		dead.emit()

################################################################################

func _on_hurt_area_entered(area: Area2D) -> void:
	if area.name.begins_with("Hit"):
		if not death_audio_player.playing:
			death_audio_player.play()
		state = PlayerState.death
	if area.get_parent() is MagicBullet:
		area.get_parent().queue_free()

func _on_pickup_area_entered(area: Area2D) -> void:
	if area is BonusArea:
		apply_bonus(area.bonus_type)

func is_mobile_web() -> bool:
	return OS.has_feature("web_android") or OS.has_feature("web_ios")
