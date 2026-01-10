extends Node2D

@onready var joystick_instance:PackedScene = preload("joystick.tscn")
@onready var joystick_spawner: TouchScreenButton = %JoystickSpawner
##The side of the screen where the joystick will appear.
@export_enum(
	"LEFT","RIGHT","BOTH"
) var side = "LEFT"
func _ready() -> void:
	Input.emulate_mouse_from_touch = true
	Input.emulate_touch_from_mouse = true
		
	joystick_spawner.shape.size.y = get_viewport().size.y
	joystick_spawner.position.y = get_viewport().size.y /2
		


func _on_joystick_spawner_pressed() -> void:
	var childrens = get_children()
	for c in childrens:
		if c is Joystick:
			c.queue_free()
	var joy = joystick_instance.instantiate()
	joy.position = get_global_mouse_position()
	add_child(joy)


func _on_joystick_spawner_released() -> void:
	if get_child_count() > 0 and get_child(1) != joystick_spawner:
		get_child(1).reset_dir()
		get_child(1).queue_free()
