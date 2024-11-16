extends Control

# Coffee Minigame variables
var currentCoffeeAmount: float = 0.0
var targetCoffeeAmount: float = 0.0 # Will be randomize to be a value between 100 and 140
var maxCoffeeAmount: float =  180.0
@export var pourSpeed: float = 60.0 # number of mL of coffee poured per second
@export var margin: float = 10.0 # Acceptable margin of error

# UI Elements
@onready var targetLabel = $TargetLabel
@onready var currentLabel = $TextureRect/CurrentLabel
@onready var resultLabel = $ResultLabel
@onready var coffeePot = $CoffeePot
@onready var spoutTip = $CoffeePot/SpoutTip
@onready var pourEffect = $CoffeePot/SpoutTip/PourEffect
@onready var cup = $Cup
@onready var coffee = $Cup/Coffee

# Rotating parameters
var running: bool = true
var is_pouring: bool = false
var pot_rotation_speed: float = 2.0  # Speed of pot rotation
var max_pot_rotation: float = -75  # Maximum rotation in degrees
var target_rotation: float = 0.0  # Target rotation angle

# Stream parameters
var min_width: float = 6.0  # Width when barely pouring
var max_width: float = 30.0  # Width when fully tilted
var min_length: float = 40.0  # Minimum stream length

# Called when the node enters the scene tree for the first time.
func _ready():
	_resetMinigame()
	running = true
	if coffeePot:
		coffeePot.rotation_degrees = -180  # Start upright
		update_stream_points()

func calculate_tilt_ratio() -> float:
	var start_angle = -180.0
	var max_tilt = max_pot_rotation - 180.0
	var current_tilt = coffeePot.rotation_degrees - start_angle
	return abs(current_tilt / max_tilt)

func calculate_stream_width() -> float:
	return lerp(min_width, max_width, calculate_tilt_ratio())

func calculate_coffee_surface_position() -> float:
	# Get the absolute position of the coffee surface
	# The coffee rectangle grows upward from the bottom of the cup
	var coffee_surface = cup.position.y + coffee.position.y
	return coffee_surface

func calculate_stream_length() -> float:
	var tilt_ratio = calculate_tilt_ratio()
	if tilt_ratio < 0.1:  # If barely tilted, use minimum length
		return min_length
		
	# Calculate distance to coffee surface
	var spout_pos = spoutTip.global_position
	var coffee_surface_y = calculate_coffee_surface_position()
	
	# Ensure the stream doesn't go below the cup bottom
	var cup_bottom = cup.position.y + cup.size.y
	var target_y = min(coffee_surface_y, cup_bottom)
	
	# Calculate the actual distance needed
	var distance = max(target_y - spout_pos.y, min_length)
	return distance

func update_stream_points():
	if not pourEffect or not is_pouring:
		pourEffect.clear_points()
		return
		
	var points = PackedVector2Array()
	var widths = PackedFloat32Array()
	var num_points = 12
	
	# Get global position of spout tip
	var start_pos = spoutTip.global_position
	points.append(start_pos)
	
	# Calculate base width from pot rotation
	var base_width = calculate_stream_width()
	widths.append(base_width)
	
	# Calculate target end position (coffee surface)
	var stream_length = calculate_stream_length()
	var relative_angle = (coffeePot.rotation_degrees + 180.0) * PI / 180.0
	var tilt_ratio = calculate_tilt_ratio()
	
	for i in range(1, num_points):
		var t = float(i) / (num_points - 1)
		
		# Start from spout tip's global position
		var x = start_pos.x
		var y = start_pos.y
		
		# Add horizontal offset based on pot's rotation
		var horizontal_offset = 40.0 * sin(relative_angle) * t * t * tilt_ratio
		x += horizontal_offset
		
		# Add vertical drop with slight curve
		var vertical_t = t * t  # Quadratic easing for more natural fall
		y += stream_length * vertical_t
		
		points.append(Vector2(x, y))
		
		# Make stream slightly wider as it falls
		var width_multiplier = 1.0 + (t * 0.5)  # Gradually increase width
		widths.append(base_width * width_multiplier)
	
	pourEffect.points = points
	pourEffect.width = base_width
	pourEffect.width_curve = create_width_curve(widths)

func create_width_curve(widths: PackedFloat32Array) -> Curve:
	var curve = Curve.new()
	for i in range(widths.size()):
		var t = float(i) / (widths.size() - 1)
		curve.add_point(Vector2(t, widths[i] / max_width))
	return curve

func reset_cup():
	$Cup/Fill_Line.position.y = $Cup.size.y - targetCoffeeAmount - 16
	$Cup/Coffee.position.y = $Cup.size.y - 16
	$Cup/Coffee.size.y = 0
	resultLabel.text = ""
	if coffeePot:
		coffeePot.rotation_degrees = -180  # Reset to upright
	update_stream_points()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	if running:
		# If coffee is currently being poured, increase the current coffee amount based on pour speed
		if Input.is_action_pressed("ui_accept") and not is_pouring:
			start_pouring()
		elif Input.is_action_pressed("ui_accept") and is_pouring:
			continue_pouring(delta)
		elif Input.is_action_just_released("ui_accept") and is_pouring:
			stop_pouring()
			
		# Smoothly animate the coffee pot rotation
		if coffeePot:
			var current_rotation = coffeePot.rotation_degrees
			var new_rotation = lerp(current_rotation, target_rotation - 180, delta * pot_rotation_speed)
			coffeePot.rotation_degrees = new_rotation
			update_stream_points()
	else:
		if Input.is_key_pressed(KEY_E):
			_close_game()

func start_pouring():
	is_pouring = true
	target_rotation = max_pot_rotation
	update_stream_points()

func continue_pouring(delta: float):
	currentCoffeeAmount += pourSpeed * delta
	currentLabel.text = "Current: %.1f mL" % currentCoffeeAmount
	$Cup/Coffee.position.y = $Cup.size.y - currentCoffeeAmount - 16
	$Cup/Coffee.size.y = currentCoffeeAmount
	update_stream_points()
	if currentCoffeeAmount > maxCoffeeAmount:
		stop_pouring()

func stop_pouring():
	is_pouring = false
	target_rotation = 0
	update_stream_points()
	if currentCoffeeAmount > 0:
		_checkCoffeeAmount()

# Checks to see if the targeted amount has been properly fulfilled
func _checkCoffeeAmount():
	if abs(currentCoffeeAmount - targetCoffeeAmount) <= margin:
		resultLabel.text = "Great Job! Nice Pouring!"
	else:
		resultLabel.text = "Ahh. Please pour the requested amount of coffee. Try again!"
	running = false
	currentLabel.text = "Press E to Continue"

# Resets the minigame to play again
func _resetMinigame():
	currentCoffeeAmount = 0.0
	targetCoffeeAmount = randi_range(40, 140)
	targetLabel.text = "Target: %d mL" % targetCoffeeAmount
	currentLabel.text = "Current: %.1f mL" % currentCoffeeAmount
	is_pouring = false
	target_rotation = 0
	reset_cup()

func _close_game():
	get_parent().hide()
	_ready()
