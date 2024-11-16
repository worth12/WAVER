extends Node2D

# Variables for tracking the pattern
var pattern_points = []  # Array of Vector2 points defining the ideal pattern
var player_points = []   # Array of Vector2 points the player has drawn
var is_drawing = false
var tolerance = 15.0
var score = 0.0
var max_score = 100.0
var minimum_points = 30  # Increased minimum points needed
var time_left = 30
var points_needed_per_segment = 8  # Increased points needed per segment

@onready var pattern_line = $PatternLine
@onready var player_line = $PlayerLine
@onready var game_timer = $Timer
@onready var score_label = $ScoreLabel
@onready var time_label = $TimeLabel

func _process(_delta):
	# Update time display based on timer's time_left property
	time_left = int(game_timer.time_left)
	update_time_display()

func _ready():
	setup_heart_pattern()
	draw_pattern()
	
	pattern_line.width = 25.0
	pattern_line.default_color = Color(0.8, 0.8, 0.8, 0.3)
	
	player_line.width = 20.0
	player_line.default_color = Color.WHITE
	
	# Set up timer
	game_timer.wait_time = 30.0  # Total time for the game
	game_timer.one_shot = true   # Timer stops after reaching 0
	game_timer.connect("timeout", _on_game_timer_timeout)
	game_timer.start()
	update_time_display()

func _on_game_timer_timeout():
	stop_drawing()
	update_time_display()

func update_time_display():
	time_label.text = "Time: " + str(time_left)

func setup_heart_pattern():
	# Simple heart pattern
	var center = get_viewport_rect().size / 2
	var size = 150
	pattern_points = [
		center + Vector2(-size, -size/2),
		center + Vector2(-size/2, -size),
		center + Vector2(0, -size/2),
		center + Vector2(size/2, -size),
		center + Vector2(size, -size/2),
		center + Vector2(0, size),
		center + Vector2(-size, -size/2)
	]

func draw_pattern():
	pattern_line.clear_points()
	for point in pattern_points:
		pattern_line.add_point(point)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_drawing(event.position)
			else:
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
	if player_points.size() >= minimum_points:
		calculate_final_score()
	else:
		score = 0.0
		update_score_display()

func add_point_to_drawing(pos: Vector2):
	player_points.append(pos)
	player_line.add_point(pos)

func calculate_score():
	# Only calculate score if we have enough points
	if player_points.size() < minimum_points:
		score = 0.0
		return

	var total_segments = pattern_points.size() - 1
	var current_segment = 0
	var points_on_current_segment = 0
	var segments_completed = 0
	var last_good_segment = -1
	
	# For each player point
	for point in player_points:
		var found_valid_point = false
		# Only look at current segment and next segment
		for i in range(current_segment, min(current_segment + 2, total_segments)):
			var start = pattern_points[i]
			var end = pattern_points[i + 1]
			var distance = get_point_line_distance(point, start, end)
			
			# If we're close enough to the segment
			if distance <= tolerance:
				points_on_current_segment += 1
				found_valid_point = true
				last_good_segment = i
				
				# If we've made enough progress on this segment, move to next
				if points_on_current_segment >= points_needed_per_segment:
					segments_completed = i + 1
					current_segment = i + 1
					points_on_current_segment = 0
				break
		
		# If point wasn't close to current or next segment, reduce score
		if not found_valid_point:
			score = max(0, score - 1)  # Penalty for straying from path
	
	# Calculate base score based on segments completed
	score = (float(segments_completed) / total_segments) * max_score
	
	# For 100% score, must complete all segments and end near the end point
	var dist_to_end = player_points[-1].distance_to(pattern_points[-1])
	if segments_completed >= total_segments and dist_to_end <= tolerance:
		# Check if they followed the path in sequence
		if last_good_segment == total_segments - 1:
			score = max_score
		else:
			score = max_score * 0.8  # Penalty for not following sequence
	else:
		score *= 0.8  # Additional penalty for not completing
	
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

func update_score_display():
	score_label.text = "Score: %d" % score
