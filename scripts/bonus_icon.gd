extends TextureRect

var enable_blink: bool = false
var current_delta: float = 0.0
var blinking: bool = false

@export var icons: Array[AtlasTexture]

func set_icon(index: int):
	texture = icons[index]

func _process(delta):
	if enable_blink:
		current_delta += delta
		if current_delta >= 0.2:
			if blinking:
				modulate = Color.GRAY
			else:
				modulate = Color.WHITE
				
			blinking = not blinking
			current_delta -= 0.2
	

func _on_blink_timer_timeout():
	enable_blink = true

func _on_remove_timer_timeout():
	queue_free()
