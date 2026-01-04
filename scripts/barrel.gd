extends CharacterBody2D

enum BarrelState {
	stand,
	rolling
}

################################################################################

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var hurt_area: Area2D = $HurtArea

################################################################################

@export var speed: float = 800.0
 
################################################################################

var player: Player = null
var state: BarrelState = BarrelState.stand
var direction: Vector2 = Vector2.ZERO

################################################################################

func _process(delta: float) -> void:
	match state:
		BarrelState.stand: stand_state(delta)
		BarrelState.rolling: rolling_state(delta)

################################################################################

func stand_state(_delta: float) -> void:
	animation_tree.play_animation("stand")

################################################################################

func rolling_state(delta: float) -> void:
	animation_tree.play_animation("rolling")
	
	velocity = direction * speed * delta
	move_and_slide()

################################################################################

func get_direction():
	player = get_tree().get_first_node_in_group("player")
	var player_position = player.global_position
	var start_position = global_position
	direction = Vector2(start_position.x - player_position.x, 0).normalized()

################################################################################

func _on_hurt_area_entered(area: Area2D) -> void:
	if area.name == "Remover":
		queue_free()
	
	if state == BarrelState.rolling:
		return

	get_direction()
	animation_tree.blend_position = direction.x
	state = BarrelState.rolling
