extends Node2D

################################################################################

@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer
@onready var bonus_spawn_timer: Timer = $BonusSpawnTimer
@onready var stones_layer = $Stones
@onready var end_screen_timer = $Stones/EndScreenTimer
@onready var hud = $HUD
@onready var end_screen = $EndScreen
@onready var score_label = $HUD/Control/MarginContainer/ScoreLabel
@onready var end_label = $EndScreen/Control/PanelContainer/MarginContainer/VBoxContainer/Label
@onready var pause_button_label = $HUD/Control2/PauseButton/Label
@onready var music_player = $AudioStreamPlayer2D
@onready var pause_label = $HUD/PauseLabel
@onready var mute_button_icon = $HUD/Control3/MuteButton/TextureRect

################################################################################

@export var min_spawn_time := 1.0
@export var base_spawn_time := 3.0
@export var base_enemy_count := 2
@export var max_enemy_count := 10
@export var enemy_list: Array[Resource]
@export var score_required_to_spawn_enemy: Array[int]
@export var enemy_weights: Array[int]

@export var bonus_list: Array[Resource]
@export var bonus_weights: Array[int]
@export var score_required_to_spawn_bonus: Array[int]
@export var bonus_fall_min_y := -50.0  # верхний предел падения относительно точки спауна
@export var bonus_fall_max_y := 50.0   # нижний предел падения относительно точки спауна
@export var min_bonus_spawn_time := 4.0
@export var base_bonus_spawn_time := 8.0
@export var base_bonus_count := 1
@export var max_bonus_count := 3

@export var mute_icon: Resource
@export var unmute_icon: Resource

var score: int = 0:
	set(value):
		score = value
		update_score_label()

var difficulty: float = 0.0
var previous_enemy_spawn_point
var previous_bonus_spawn_point
var paused: bool = false
var muted: bool = false

################################################################################

func _ready():
	_on_enemy_spawn_timer_timeout()
	_on_bonus_spawn_timer_timeout()

################################################################################

func _on_player_dead() -> void:
	_stop_game()
	
func _on_the_last_support_destroy() -> void:
	_stop_game()

################################################################################

func _stop_game():
	var objects = get_tree().get_nodes_in_group("characters")
  
	for obj in objects:
		obj.set_process_mode(Node.PROCESS_MODE_DISABLED)
		
	end_screen_timer.start(1.0)
	var stones = get_tree().get_nodes_in_group("stones")
	stones_layer.visible = true
	for stone in stones:
		(stone as AnimatedSprite2D).play("default")

################################################################################

func _on_pause_button_pressed():
	if not paused:
		pause_button_label.text = "Resume"
		pause_label.visible = true
		
		var objects = get_tree().get_nodes_in_group("characters")
		
		for obj in objects:
			obj.set_process_mode(Node.PROCESS_MODE_DISABLED)
			
		music_player.stream_paused = true
	
	else:
		pause_button_label.text = "Pause"
		pause_label.visible = false
		
		var objects = get_tree().get_nodes_in_group("characters")
		
		for obj in objects:
			obj.set_process_mode(Node.PROCESS_MODE_INHERIT)
			
		music_player.stream_paused = false
			
	paused = not paused

################################################################################

func update_difficulty():
	difficulty = log(score + 1) * 0.5
	
################################################################################

func get_spawn_time() -> float:
	var t = base_spawn_time * exp(-difficulty * 0.15)
	return max(t, min_spawn_time)
	
################################################################################

func get_enemy_count() -> int:
	var count = base_enemy_count + int(difficulty)
	return min(count, max_enemy_count)
	
################################################################################

func get_enemy_weight(i: int) -> int:
	var base = enemy_weights[i]
	var unlock_score = score_required_to_spawn_enemy[i]

	if score < unlock_score:
		return 0

	var t = clamp(float(score - unlock_score) / 100.0, 0.0, 1.0)
	return int(base * t)
	
################################################################################

func pick_weighted_enemy_smooth(max_id: int) -> int:
	var total := 0
	var weights := []

	for i in range(max_id):
		var w = get_enemy_weight(i)
		weights.append(w)
		total += w

	var roll = randi_range(1, total)
	var acc := 0

	for i in range(max_id):
		acc += weights[i]
		if roll <= acc:
			return i

	return 0
	
################################################################################

func _on_enemy_spawn_timer_timeout():
	update_difficulty()

	var spawn_points = get_tree().get_nodes_in_group("enemy_spawn_point")
	var parent_node = get_tree().get_first_node_in_group("spawn_here")

	# сколько типов врагов доступно
	var current_enemy_types := 0
	for req in score_required_to_spawn_enemy:
		if score >= req:
			current_enemy_types += 1

	# сколько врагов спавнить
	var spawn_count = get_enemy_count()

	# перезапуск таймера следующей волны
	enemy_spawn_timer.start(get_spawn_time())

	# спавним врагов с небольшой паузой
	spawn_enemies_with_delay(spawn_count, spawn_points, parent_node, current_enemy_types)

################################################################################

func spawn_enemies_with_delay(count: int, spawn_points: Array, parent_node: Node, max_enemy_types: int) -> void:
	for i in range(count):
		# выбираем точку спауна
		var point_id = randi_range(0, spawn_points.size() - 1)
		while point_id == previous_enemy_spawn_point:
			point_id = randi_range(0, spawn_points.size() - 1)
		previous_enemy_spawn_point = point_id

		# выбираем тип врага
		var enemy_id = pick_weighted_enemy_smooth(max_enemy_types)
		var new_enemy = enemy_list[enemy_id].instantiate()
		new_enemy.global_position = spawn_points[point_id].global_position
		parent_node.add_child(new_enemy)

		# небольшая задержка перед следующим врагом
		await get_tree().create_timer(0.1).timeout
		
################################################################################

func get_bonus_weight(i: int) -> int:
	if score < score_required_to_spawn_bonus[i]:
		return 0

	var base_weight = bonus_weights[i]
	var unlock_score = score_required_to_spawn_bonus[i]

	# плавное “вкатывание” шанса
	var t = clamp(float(score - unlock_score) / 150.0, 0.0, 1.0)
	return int(base_weight * t)
	
################################################################################

func pick_weighted_bonus(max_id: int) -> int:
	var total := 0
	var weights := []

	for i in range(max_id):
		var w = get_bonus_weight(i)
		weights.append(w)
		total += w

	var roll = randi_range(1, total)
	var acc := 0

	for i in range(max_id):
		acc += weights[i]
		if roll <= acc:
			return i

	return 0
	
################################################################################

func get_bonus_spawn_time() -> float:
	var t = base_bonus_spawn_time * exp(-difficulty * 0.15)
	return max(t, min_bonus_spawn_time)
	
################################################################################

func get_bonus_count() -> int:
	var count = base_bonus_count + int(difficulty)
	return min(count, max_bonus_count)
	
################################################################################

func _on_bonus_spawn_timer_timeout():
	update_difficulty()

	# Получаем точки спауна бонусов
	var spawn_points = get_tree().get_nodes_in_group("bonus_spawn_point")
	var parent_node = get_tree().get_first_node_in_group("spawn_here")

	# Определяем, сколько типов бонусов доступны
	var current_bonus_types = 0
	for req in score_required_to_spawn_bonus:
		if score >= req:
			current_bonus_types += 1

	var bonus_count = get_bonus_count()

	# перезапуск таймера
	bonus_spawn_timer.start(get_bonus_spawn_time())

	# спавним бонусы с небольшой паузой
	spawn_bonuses_with_delay(bonus_count, spawn_points, parent_node, current_bonus_types)
	
################################################################################

func spawn_bonuses_with_delay(count: int, spawn_points: Array, parent_node: Node, max_bonus_types: int) -> void:
	for i in range(count):
		# выбираем точку спауна
		var point_id = randi_range(0, spawn_points.size() - 1)
		while point_id == previous_enemy_spawn_point:
			point_id = randi_range(0, spawn_points.size() - 1)
		previous_bonus_spawn_point = point_id

		var spawn_pos = spawn_points[point_id].global_position
		spawn_pos.y = randf_range(bonus_fall_min_y, bonus_fall_max_y)
		
		# выбираем тип бонуса
		var bonus_id = pick_weighted_bonus(max_bonus_types)
		var new_bonus = bonus_list[bonus_id].instantiate()
		new_bonus.global_position = spawn_pos
		parent_node.add_child(new_bonus)

		# небольшая задержка перед следующим врагом
		await get_tree().create_timer(0.2).timeout

################################################################################

func _on_end_screen_timer_timeout():
	hud.visible = false
	end_screen.visible = true
	end_label.text = "The last support has fallen. The fortress collapses.\nScore: " + str(score)

################################################################################

func update_score_label():
	score_label.text = "Score: " + str(score)

################################################################################

func restart_game():
	get_tree().paused = false
	get_tree().reload_current_scene()

################################################################################

func _on_button_pressed():
	restart_game()

################################################################################

func _on_mute_button_pressed():
	var bus = AudioServer.get_bus_index("Master")
	
	if not muted:
		AudioServer.set_bus_mute(bus, true)
		mute_button_icon.texture = mute_icon
	else:
		AudioServer.set_bus_mute(bus, false)
		mute_button_icon.texture = unmute_icon
	
	muted = not muted
