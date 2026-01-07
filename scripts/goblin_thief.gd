class_name GoblinThie extends CharacterBody2D

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
@onready var animation_player: AnimationPlayer = $AnimationPlayer

################################################################################

@export var speed: float = 90.0
@export var attack_range: float = 25.0

################################################################################

var target: CharacterBody2D = null
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
	
	if not target:
		if randi_range(0, 9) >= 1:
			target = get_tree().get_first_node_in_group("player")
		else:
			target = get_tree().get_first_node_in_group("support")
		
	if not target:
		return
		
	if check_attack_range():
		state = GoblinThiefState.attack
	else:
		state = GoblinThiefState.run
	
################################################################################

func run_state(delta: float) -> void:
	if not target:
		state = GoblinThiefState.idle
		return
	
	if check_attack_range():
		state = GoblinThiefState.attack
		return
		
	animation_tree.play_animation("run")
	
	velocity = global_position.direction_to(target.global_position).normalized() * speed * Global.time_scale
	animation_tree.blend_position = velocity.normalized().x

	move_and_slide()
	
################################################################################

func attack_state(_delta: float) -> void:
	if not target:
		state = GoblinThiefState.idle
		return
		
	animation_tree.play_animation("attack")
	
################################################################################

func death_state(_delta: float) -> void:
	animation_tree.play_animation("death")
	
################################################################################

func check_attack_range() -> bool:
	if not target:
		return false
	
	if position.distance_to(target.position) <= attack_range:
		return true
		
	return false

################################################################################

func _on_hurtbox_area_entered(area):
	state = GoblinThiefState.death
	if area.get_parent() is MagicBullet:
		area.get_parent().queue_free()

################################################################################

func _on_animation_tree_animation_finished(anim_name):
	if anim_name.begins_with("attack"):
		if not check_attack_range():
			state = GoblinThiefState.run

	if anim_name == "death":
		get_tree().get_first_node_in_group("root").score += 1
		queue_free()
