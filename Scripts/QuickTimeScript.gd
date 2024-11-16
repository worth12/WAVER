extends Control

@export var speed: float = 200.0  # Pixels per second
var direction: int = 1            # Moving up (1) or down (-1)

# Define the green and orange zones
@export var green_zone_start: float = 300  # Start position of the green zone (pixels)
@export var green_zone_end: float = 500    # End position of the green zone (pixels)
@export var orange_zone_start_1: float = 100
@export var orange_zone_end_1: float = 200
@export var orange_zone_start_2: float = 600
@export var orange_zone_end_2: float = 700

@onready var score_boxes = [$ScoreContainer/score1, $ScoreContainer/score2, $ScoreContainer/score3]
var score_textures = ["res://Assets/8445903.png", "res://Assets/8445922.png", "res://Assets/8445773.png"]

var try: int = 0
var running: bool = true

# Indicator movement
var indicator_y: float = 0  # Current Y position of the indicator

func _ready():
	# Initialize the starting position of the indicator
	indicator_y = 0
	try = 0
	running = true
	update_indicator_position()
	reset_score()
	$Continue.text = "Press Space To Stop"

func _process(delta):
	if running:
		# Move the indicator
		indicator_y += direction * speed * delta

		# Check if it hits the edges of the Slider
		if indicator_y >= $Slider.size.y - $Slider/Indicator.size.y:  # Bottom edge
			direction = -1
		elif indicator_y <= 0:  # Top edge
			direction = 1

		# Update the indicator position
		update_indicator_position()
	else:
		if Input.is_key_pressed(KEY_E):
			get_parent().hide()
			_ready()

func update_indicator_position():
	$Slider/Indicator.position.y = indicator_y

func _input(event):
	if try != 3:
		if event.is_action_pressed("ui_accept"):
			check_hit()

func check_hit():
	# Get the indicator's position
	var indicator_pos = $Slider/Indicator.position.y + ($Slider/Indicator.size.y/2)

	# Check if the indicator is in the green or orange zones
	if (green_zone_start <= indicator_pos) && (indicator_pos <= green_zone_end):
		show_score(0) # Green zone success
	elif ((orange_zone_start_1 <= indicator_pos) && (indicator_pos <= orange_zone_end_1)) or (orange_zone_start_2 <= indicator_pos) && (indicator_pos <= orange_zone_end_2):
		show_score(1) # Orange zone success
	else:
		show_score(2) # Missed entirely
	if try == 3:
		$Continue.text = "Press E To Continue"
		running = false

func show_score(score):
	score_boxes[try].texture = ResourceLoader.load(score_textures[score])
	try += 1

func reset_score():
	try = 0
	for score_box in score_boxes:
		score_box.texture = null
