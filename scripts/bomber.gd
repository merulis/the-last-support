class_name Bomber extends CharacterBody2D

################################################################################

enum BomberState {
	idle,
	run,
	boom,
	death
}

################################################################################

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var hurt_area: Area2D = $HurtArea
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var boom_audio_player = $BoomAudioPlayer

################################################################################

@export var speed: float = 2000.0
@export var attack_range: float = 25.0
@export var bomb: Resource

################################################################################

var target: CharacterBody2D = null
var state: BomberState = BomberState.idle
var time_scale: float = 1.0:
	set(value):
		time_scale = value
		animation_player.speed_scale = value

################################################################################

func _process(delta: float) -> void:
	match state:
		BomberState.idle: idle_state(delta)
		BomberState.run: run_state(delta)
		BomberState.boom: boom_state(delta)
		BomberState.death: death_state(delta)

################################################################################

func idle_state(_delta: float) -> void:
	animation_tree.play_animation("idle")
	
	if not target:
		if randi_range(0,9) > 2:
			target = get_tree().get_first_node_in_group("player")
		else:
			target = get_tree().get_first_node_in_group("support")
				
	if not target:
		return
		
	if check_attack_range():
		state = BomberState.boom
	else:
		state = BomberState.run
	
################################################################################

func run_state(delta: float) -> void:
	if not target:
		state = BomberState.idle
		return
	
	if check_attack_range():
		state = BomberState.boom
		return
		
	animation_tree.play_animation("run")
	
	velocity = global_position.direction_to(target.global_position).normalized() * speed * delta * time_scale
	animation_tree.blend_position = velocity.normalized().x

	move_and_slide()
	
################################################################################

func boom_state(_delta: float) -> void:
	if not target:
		state = BomberState.idle
		return
		
	animation_tree.play_animation("boom")
	
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

func drop_bomb():
	var spawn_here = get_tree().get_first_node_in_group("spawn_here")
	var new_bomb: Bomb = bomb.instantiate()
	new_bomb.global_position = global_position
	spawn_here.add_child(new_bomb)

################################################################################

func _on_hurt_area_entered(area: Area2D) -> void:
	state = BomberState.death
		
	if area.get_parent() is MagicBullet:
		area.get_parent().queue_free()

################################################################################

func _on_animation_tree_animation_finished(anim_name: StringName):
	if anim_name == "death":
		drop_bomb()
		get_tree().get_first_node_in_group("root").score += 2
		queue_free()
	elif anim_name.begins_with("boom"):
		if boom_audio_player.playing:
			if boom_audio_player.get_parent() == self:
				remove_child(boom_audio_player)
				get_tree().get_first_node_in_group("spawn_here").add_child(boom_audio_player)
				boom_audio_player.finished.connect(boom_audio_player.queue_free)
		queue_free()
