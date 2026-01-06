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
@onready var bullet_start_position: Marker2D = $BulletStartPosition
@onready var animation_player: AnimationPlayer = $AnimationPlayer

################################################################################

@export var speed: float = 75.0
@export var attack_range: float = 200.0
@export var bullet: Resource

################################################################################

var player: Player = null
var state: MageState = MageState.idle
var time_scale: float = 1.0:
	set(value):
		time_scale = value
		animation_player.speed_scale = value
var can_spawn: bool = true

################################################################################

func _process(delta: float) -> void:
	match state:
		MageState.idle: 
			idle_state(delta)
		MageState.run: 
			run_state(delta)
		MageState.attack: 
			attack_state(delta)
		MageState.death: 
			death_state(delta)

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
	
	velocity = global_position.direction_to(player.global_position).normalized() * speed * time_scale
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
		get_tree().get_first_node_in_group("root").score += 3
		queue_free()
	

################################################################################

func _on_hurt_area_entered(area: Area2D) -> void:
	state = MageState.death
		
	if area.get_parent() is MagicBullet:
		area.get_parent().queue_free()

################################################################################

func create_bullet() -> void:
	if can_spawn:
		var spawn_here = get_tree().get_first_node_in_group("spawn_here")
		var new_bullet = bullet.instantiate()
		new_bullet.global_position = bullet_start_position.global_position
		spawn_here.add_child(new_bullet)
		can_spawn = false
		$Timer.start(0.2)

################################################################################

func go_run_state() -> void:
	state = MageState.run
	
################################################################################

func _on_timer_timeout():
	can_spawn = true
