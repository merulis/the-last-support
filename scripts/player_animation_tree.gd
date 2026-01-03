extends AnimationTree

################################################################################

@export var blend_position: float = 0.0 :
	set = _set_blend_position

################################################################################

func _set_blend_position(direction: float) -> void:
	blend_position = direction
	set("parameters/StateMachine/idle/blend_position", blend_position)
	set("parameters/StateMachine/run/blend_position", blend_position)
	set("parameters/StateMachine/attack/blend_position", blend_position)
	set("parameters/StateMachine/death/blend_position", blend_position)

################################################################################

func play_animation(anim_name: String) -> void:
	get("parameters/StateMachine/playback").travel(anim_name)
