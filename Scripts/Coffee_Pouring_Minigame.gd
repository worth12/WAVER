extends Control

# Coffee Minigame variables
var currentCoffeeAmount: float = 0.0
var targetCoffeeAmount: float = 0.0 # Will be randomize to be a value between 100 and 300
@export var pourSpeed: float = 60.0 # number of mL of coffee poured per second
@export var margin: float = 10.0 # Acceptable margin of error

# UI Elements
@onready var targetLabel = $TargetLabel
@onready var currentLabel = $TextureRect/CurrentLabel
@onready var resultLabel = $ResultLabel
@onready var coffeePot = $CoffeePot
@onready var pourAnimation = $CoffeePot/PourEffect

var running: bool = true
var is_pouring: bool = false
var pot_rotation_speed: float = 2.0  # Speed of pot rotation
var max_pot_rotation: float = -75  # Maximum rotation in degrees
var target_rotation: float = 0.0  # Target rotation angle


# Called when the node enters the scene tree for the first time.
func _ready():
	_resetMinigame()
	running = true
	# Initialize coffee pot in upright position
	if coffeePot:
		coffeePot.rotation_degrees = -180  # Start upright

func reset_cup():
	$Cup/Fill_Line.position.y = $Cup.size.y - targetCoffeeAmount - 16
	$Cup/Coffee.position.y = $Cup.size.y - 16
	$Cup/Coffee.size.y = 0
	resultLabel.text = ""
	if coffeePot:
		coffeePot.rotation_degrees = -180  # Reset to upright
	if pourAnimation:
		pourAnimation.hide()


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
			coffeePot.rotation_degrees = lerp(current_rotation, target_rotation - 180, delta * pot_rotation_speed)
	else:
		if Input.is_key_pressed(KEY_E):
			_close_game()

func start_pouring():
	is_pouring = true
	target_rotation = max_pot_rotation
	if pourAnimation:
		pourAnimation.show()

func continue_pouring(delta: float):
	currentCoffeeAmount += pourSpeed * delta
	currentLabel.text = "Current: %.1f mL" % currentCoffeeAmount
	$Cup/Coffee.position.y = $Cup.size.y - currentCoffeeAmount - 16
	$Cup/Coffee.size.y = currentCoffeeAmount

func stop_pouring():
	is_pouring = false
	target_rotation = 0
	if pourAnimation:
		pourAnimation.hide()
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
