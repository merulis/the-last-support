extends CharacterBody2D

enum BarrelState {
	stand,
	rolling
}

################################################################################

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var hurt_area: Area2D = $HurtArea

################################################################################

@export var speed: float = 200.0
 
################################################################################

var player: Player = null
var state: BarrelState = BarrelState.stand

################################################################################

func _process(delta: float) -> void:
	match state:
		BarrelState.stand: stand_state(delta)
		BarrelState.rolling: rolling_state(delta)

################################################################################

func stand_state(_delta: float) -> void:
	animation_tree.play_animation("stand")

################################################################################

func rolling_state(_delta: float) -> void:
	animation_tree.play_animation("rolling")
	
	move_and_slide()

################################################################################

func _on_hurt_area_entered(area: Area2D) -> void:
	if area.name == "Remover":
		queue_free()
	
	var player_position = get_tree().get_first_node_in_group("player").global_position.normalized()
	var direction = global_position.direction_to(player_position)
	velocity = Vector2(-direction.x, 0) * speed
	animation_tree.blend_position = velocity.normalized().x
	state = BarrelState.rolling
