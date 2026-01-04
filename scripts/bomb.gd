class_name Bomb extends CharacterBody2D

enum BombState {
	fuse,
	pushed,
	boom
}

################################################################################

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hit_area: Area2D = $HitArea
@onready var hurt_area: Area2D = $HurtArea
@onready var sprite: Sprite2D = $Sprite2D
@onready var timer: Timer = $Timer
@onready var boom_audio_player = $BoomAudioPlayer

################################################################################

@export var speed: float = 800.0
 
################################################################################

var player: Player = null
var state: BombState = BombState.fuse
var direction: Vector2 = Vector2.ZERO
var time_scale: float = 1.0:
	set(value):
		time_scale = value
		timer.time_scale = value
		animation_player.speed_scale = value

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
	velocity = direction * speed * delta * time_scale
	move_and_slide()

################################################################################

func boom_state(_delta: float) -> void:
	sprite.z_index = 1
	if not boom_audio_player.playing:
		boom_audio_player.play()
	animation_tree.play_animation("boom")

################################################################################

func get_direction():
	player = get_tree().get_first_node_in_group("player")
	direction = Vector2(player.global_position.direction_to(global_position).x, 0).normalized()

################################################################################

func _on_hurt_area_entered(area: Area2D) -> void:
	if state == BombState.boom:
		return
		
	if state == BombState.pushed:
		state = BombState.boom
		return

	get_direction()
	state = BombState.pushed
	hit_area.set_collision_layer_value(2, false)
	hit_area.set_collision_layer_value(7, false)
	hurt_area.set_collision_mask_value(3, false)
	hurt_area.set_collision_mask_value(6, true)
		
	if area.get_parent() is MagicBullet:
		area.get_parent().queue_free()

################################################################################

func _on_timer_timeout() -> void:
	state = BombState.boom

################################################################################

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "boom":
		queue_free()
