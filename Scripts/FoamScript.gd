extends Control

@export var speed: float = 200.0  # Pixels per second
var direction: int = 1            # Moving up (1) or down (-1)

# Define the zones as percentages of the slider height
@export var green_zone_start: float = 0.4  
@export var green_zone_end: float = 0.5    
@export var orange_zone_start_1: float = 0.3
@export var orange_zone_end_1: float = 0.4
@export var orange_zone_start_2: float = 0.5
@export var orange_zone_end_2: float = 0.6

@onready var score_boxes = [$ScoreContainer/score1, $ScoreContainer/score2, $ScoreContainer/score3]
var score_textures = ["res://Assets/8445903.png", "res://Assets/8445922.png", "res://Assets/8445773.png"]

var try: int = 0
var running: bool = true

signal minigame_completed(minigame_name: String, score: int)

var current_score: int = 0
var attempt_scores: Array = []

# Points for each zone
const GREEN_ZONE_POINTS = 100
const ORANGE_ZONE_POINTS = 60
const MISS_POINTS = 20

# Indicator movement
var indicator_percentage: float = 0.0

func _ready():
	_resetMinigame()
	update_indicator_position()
	reset_score()
	$Continue.text = "Press Space To Stop"
	
	# Create score label if it doesn't exist
	if !has_node("ScoreLabel"):
		var label = Label.new()
		label.name = "ScoreLabel"
		label.position = Vector2(376, 100)
		label.add_theme_font_size_override("font_size", 24)
		add_child(label)
	$ScoreLabel.text = "Score: 0"
	
	# Update zone positions based on slider height
	var slider_height = $Slider.size.y
	$Slider/green_zone.position.y = slider_height * green_zone_start
	$Slider/green_zone.size.y = slider_height * (green_zone_end - green_zone_start)
	
	$Slider/orange_zone_1.position.y = slider_height * orange_zone_start_1
	$Slider/orange_zone_1.size.y = slider_height * (orange_zone_end_1 - orange_zone_start_1)
	
	$Slider/orange_zone_2.position.y = slider_height * orange_zone_start_2
	$Slider/orange_zone_2.size.y = slider_height * (orange_zone_end_2 - orange_zone_start_2)

func _process(delta):
	if running:
		# Move the indicator
		indicator_percentage += direction * (speed / $Slider.size.y) * delta

		# Check if it hits the edges of the Slider
		if indicator_percentage >= 1.0:  # Bottom edge
			direction = -1
			indicator_percentage = 1.0
		elif indicator_percentage <= 0.0:  # Top edge
			direction = 1
			indicator_percentage = 0.0

		# Update the indicator position
		update_indicator_position()
	else:
		if Input.is_key_pressed(KEY_E):
			_close_game()

func update_indicator_position():
	var slider_height = $Slider.size.y - $Slider/Indicator.size.y
	$Slider/Indicator.position.y = indicator_percentage * slider_height

func _input(event):
	if try != 3:
		if event.is_action_pressed("ui_accept"):
			check_hit()

func check_hit():
	# Get the indicator's position as a percentage
	var indicator_pos = indicator_percentage
	var points = 0
	
	# Check if the indicator is in the green or orange zones
	if green_zone_start <= indicator_pos and indicator_pos <= green_zone_end:
		show_score(0) # Green zone success
		points = GREEN_ZONE_POINTS
	elif (orange_zone_start_1 <= indicator_pos and indicator_pos <= orange_zone_end_1) or \
		 (orange_zone_start_2 <= indicator_pos and indicator_pos <= orange_zone_end_2):
		show_score(1) # Orange zone success
		points = ORANGE_ZONE_POINTS
	else:
		show_score(2) # Missed entirely
		points = MISS_POINTS
	
	attempt_scores.append(points)
	current_score = calculate_current_score()
	$ScoreLabel.text = "Score: %d" % current_score
		
	if try == 3:
		$Continue.text = "Press E To Continue"
		running = false
	else:
		indicator_percentage = 0.0

func calculate_current_score() -> int:
	if attempt_scores.is_empty():
		return 0
	var total = 0
	for score in attempt_scores:
		total += score
	return total / attempt_scores.size()

func show_score(score):
	score_boxes[try].texture = ResourceLoader.load(score_textures[score])
	try += 1

func reset_score():
	try = 0
	for score_box in score_boxes:
		score_box.texture = null
	attempt_scores.clear()
	current_score = 0
	if has_node("ScoreLabel"):
		$ScoreLabel.text = "Score: 0"

func _resetMinigame():
	indicator_percentage = 0.0
	try = 0
	running = true
	current_score = 0
	attempt_scores.clear()

func _close_game():
	get_parent().hide()
	emit_signal("minigame_completed", "foam", current_score)  # Notify MinigameController
	_ready()
	
# Called when the window is resized
func _notification(what):
	if what == NOTIFICATION_RESIZED:
		# Update zone positions when window is resized
		var slider_height = $Slider.size.y
		$Slider/green_zone.position.y = slider_height * green_zone_start
		$Slider/green_zone.size.y = slider_height * (green_zone_end - green_zone_start)
		
		$Slider/orange_zone_1.position.y = slider_height * orange_zone_start_1
		$Slider/orange_zone_1.size.y = slider_height * (orange_zone_end_1 - orange_zone_start_1)
		
		$Slider/orange_zone_2.position.y = slider_height * orange_zone_start_2
		$Slider/orange_zone_2.size.y = slider_height * (orange_zone_end_2 - orange_zone_start_2)
