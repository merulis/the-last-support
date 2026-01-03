extends AnimationTree

################################################################################

func play_animation(anim_name: String) -> void:
	get("parameters/playback").travel(anim_name)
