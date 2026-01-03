extends CharacterBody2D

@onready var goblin_sprite: Sprite2D = $GoblinSprite
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var hurtbox: Hurtbox = $HurtboxArea
@onready var playback = animation_tree.get("parameters/StateMachine/playback") as AnimationNodeStateMachinePlayback

@export var player: Player

const SPEED = 50.0

func _ready() -> void:
	hurtbox.hurt.connect(func(hitbox: Hitbox):
		queue_free()
	)

func _physics_process(_delta: float) -> void:
	var state = playback.get_current_node()
	match state:
		"Idle": pass
		"ChaseState": chase_state(_delta)
		"Attack": pass
		"Die": pass

func chase_state(delta: float) -> void:
	var player = get_player()
	if player is Player:
		velocity = global_position.direction_to(player.global_position).normalized() * SPEED
		update_blend(velocity.normalized().x)
	else:
		velocity = Vector2.ZERO

	move_and_slide()

func get_player() -> Player:
	return get_tree().get_first_node_in_group("player")

func is_player() -> bool:
	var result = false
	var player = get_player()
	if player is Player:
		result = true
	
	return result
	
func update_blend(x: float) -> void:
	animation_tree.set("parameters/StateMachine/ChaseState/blend_position", x)
