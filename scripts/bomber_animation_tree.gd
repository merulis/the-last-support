extends AnimationTree

################################################################################

@export var blend_position: float = 0.0 :
	set = _set_blend_position

################################################################################

func _set_blend_position(direction: float) -> void:
	blend_position = direction
	set("parameters/idle/blend_position", blend_position)
	set("parameters/run/blend_position", blend_position)
	set("parameters/boom/blend_position", blend_position)

################################################################################

func play_animation(anim_name: String) -> void:
	get("parameters/playback").travel(anim_name)
