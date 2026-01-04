class_name SmallSlime extends CharacterBody2D

################################################################################

enum SlimeState {
	idle,
	jump,
	death
}

################################################################################

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var invul_timer: Timer = $InvulTimer
@onready var hurt_area: Area2D = $HurtArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer

################################################################################

@export var speed: float = 2000.0

################################################################################

var player: Player = null
var state: SlimeState = SlimeState.idle
var direction: Vector2 = Vector2.ZERO
var time_scale: float = 1.0:
	set(value):
		time_scale = value
		animation_player.speed_scale = value

################################################################################

func _ready() -> void:
	invul_timer.start()
	hurt_area.monitoring = false
	

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
	velocity = direction * speed * delta * time_scale
	animation_tree.blend_position = velocity.normalized().x

	move_and_slide()
	
################################################################################

func death_state(_delta: float) -> void:
	animation_tree.play_animation("death")

################################################################################

func _on_hurt_area_entered(_area: Area2D) -> void:
	state = SlimeState.death

func _on_animation_tree_animation_finished(anim_name: StringName):
	if anim_name.begins_with("death"):
		get_tree().get_first_node_in_group("root").score += 1
		queue_free()

func _on_invul_timer_timeout() -> void:
	hurt_area.monitoring = true
