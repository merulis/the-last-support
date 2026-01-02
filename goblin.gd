extends CharacterBody2D

@onready var goblin_sprite: Sprite2D = $GoblinSprite
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var hurtbox: Hurtbox = $HurtboxArea
@onready var playback = animation_tree.get("parameters/StateMachine/playback") as AnimationNodeStateMachinePlayback

func _ready() -> void:
	hurtbox.hurt.connect(func(hitbox: Hitbox):
		queue_free()
	)

func _physics_process(_delta: float) -> void:
	var state = playback.get_current_node()
	match state:
		"Idle": pass
		"Chase": pass
		"Attack": pass
		"Die": pass
		
