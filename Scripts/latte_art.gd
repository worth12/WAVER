extends Node2D

enum Patterns { HEART, ZIGZAG, STAR }

var pattern_points = []
var player_points = []
var is_drawing = false
var has_drawn = false
var tolerance = 10.0
var score = 0.0
var max_score = 100.0
var minimum_points = 30
var time_left = 30
var points_needed_per_segment = 8
var current_pattern = Patterns.HEART

@onready var pattern_line = $PatternLine
@onready var player_line = $PlayerLine
@onready var game_timer = $Timer
@onready var score_label = $ScoreLabel
@onready var time_label = $TimeLabel
@onready var instructions = $Instructions

func _process(_delta):
	time_left = int(game_timer.time_left)
	update_time_display()
	if player_points.size() > 0:
		if has_drawn && Input.is_key_pressed(KEY_E):
			_close_game()
		else:
			pass

func _ready():
	has_drawn = false
	score = 0
	instructions.text = "Trace the pattern to create latte art!"
	randomize()
	current_pattern = randi() % Patterns.size()
	setup_pattern()
	draw_pattern()
	
	pattern_line.width = 25.0
	pattern_line.default_color = Color(1, 1, 1, 0.4)
	
	player_line.width = 20.0
	player_line.default_color = Color(1, 1, 1, 1)
	
	game_timer.wait_time = 30.0
	game_timer.one_shot = true
	game_timer.connect("timeout", _on_game_timer_timeout)
	game_timer.start()
	update_time_display()

func setup_pattern():
	var center = get_viewport_rect().size / 2
	var size = 150
	
	match current_pattern:
		Patterns.HEART:
			setup_heart_pattern(center, size)
		Patterns.ZIGZAG:
			setup_zigzag_pattern(center, size)
		Patterns.STAR:
			setup_star_pattern(center, size)

func setup_heart_pattern(center: Vector2, size: float):
	pattern_points = [
		center + Vector2(-size, -size/2),
		center + Vector2(-size/2, -size),
		center + Vector2(0, -size/2),
		center + Vector2(size/2, -size),
		center + Vector2(size, -size/2),
		center + Vector2(0, size),
		center + Vector2(-size, -size/2)
	]

func setup_zigzag_pattern(center: Vector2, size: float):
	pattern_points = []
	var num_zigs = 4
	var width = size * 2
	var height = size * 1.5
	var segment_width = width / (num_zigs - 1)
	
	for i in range(num_zigs * 2 - 1):
		var x = center.x - width/2 + (i * segment_width/2)
		var y = center.y + (height/2 if i % 2 == 0 else -height/2)
		pattern_points.append(Vector2(x, y))

func setup_star_pattern(center: Vector2, size: float):
	pattern_points = []
	var num_points = 5
	var outer_radius = size
	var inner_radius = size * 0.4
	
	for i in range(num_points * 2 + 1):
		var radius = outer_radius if i % 2 == 0 else inner_radius
		var angle = (i * PI * 2) / (num_points * 2)
		var point = center + Vector2(
			cos(angle - PI/2) * radius,
			sin(angle - PI/2) * radius
		)
		pattern_points.append(point)

func draw_pattern():
	pattern_line.clear_points()
	for point in pattern_points:
		pattern_line.add_point(point)

func _input(event):
	if event is InputEventMouseButton and not has_drawn:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_drawing(event.position)
			elif is_drawing:
				stop_drawing()
	elif event is InputEventMouseMotion and is_drawing:
		continue_drawing(event.position)

func start_drawing(pos: Vector2):
	is_drawing = true
	player_points.clear()
	player_line.clear_points()
	add_point_to_drawing(pos)

func continue_drawing(pos: Vector2):
	if is_drawing:
		add_point_to_drawing(pos)
		calculate_score()

func stop_drawing():
	is_drawing = false
	has_drawn = true
	if player_points.size() >= minimum_points:
		calculate_final_score()
		instructions.text = "Press E to Continue"
	else:
		score = 0.0
		update_score_display()

func add_point_to_drawing(pos: Vector2):
	player_points.append(pos)
	player_line.add_point(pos)

func calculate_score():
	if player_points.size() < minimum_points:
		score = 0.0
		return

	var total_segments = pattern_points.size() - 1
	var current_segment = 0
	var points_on_current_segment = 0
	var segments_completed = 0
	var last_good_segment = -1
	
	for point in player_points:
		var found_valid_point = false
		for i in range(current_segment, min(current_segment + 2, total_segments)):
			var start = pattern_points[i]
			var end = pattern_points[i + 1]
			var distance = get_point_line_distance(point, start, end)
			
			if distance <= tolerance:
				points_on_current_segment += 1
				found_valid_point = true
				last_good_segment = i
				
				if points_on_current_segment >= points_needed_per_segment:
					segments_completed = i + 1
					current_segment = i + 1
					points_on_current_segment = 0
				break
		
		if not found_valid_point:
			score = max(0, score - 1)
	
	score = (float(segments_completed) / total_segments) * max_score
	
	var dist_to_end = player_points[-1].distance_to(pattern_points[-1])
	if segments_completed >= total_segments and dist_to_end <= tolerance:
		if last_good_segment == total_segments - 1:
			score = max_score
		else:
			score = max_score * 0.8
	else:
		score *= 0.8
	
	update_score_display()

func get_point_line_distance(point: Vector2, line_start: Vector2, line_end: Vector2) -> float:
	var line_vec = line_end - line_start
	var point_vec = point - line_start
	var line_length = line_vec.length()
	if line_length == 0:
		return point_vec.length()
	
	var t = max(0, min(1, point_vec.dot(line_vec) / (line_length * line_length)))
	var projection = line_start + t * line_vec
	return (point - projection).length()

func calculate_final_score():
	if player_points.size() < minimum_points:
		score = 0.0
	update_score_display()

func _on_game_timer_timeout():
	stop_drawing()
	update_time_display()

func update_time_display():
	time_label.text = "Time: " + str(time_left)

func update_score_display():
	score_label.text = "Score: %d" % score
	
func _resetMinigame():
	stop_drawing()
	player_line.clear_points()
	player_points.clear()
	randomize()
	current_pattern = randi() % Patterns.size()
	setup_pattern()
	draw_pattern()
	
func _close_game():
	get_parent().hide()
	_resetMinigame()
	_ready()
	
