extends Control

# Coffee Minigame variables
var currentCoffeeAmount: float = 0.0
var targetCoffeeAmount: float = 0.0 # Will be randomize to be a value between 100 and 300
@export var pourSpeed: float = 40.0 # number of mL of coffee poured per second
@export var margin: float = 10.0 # Acceptable margin of error

# UI Elements
@onready var targetLabel = $TargetLabel
@onready var currentLabel = $TextureRect/CurrentLabel
@onready var resultLabel = $ResultLabel

var running: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	# Initialize a target coffee amount to a value between 100 and 300 mL
	_resetMinigame()
	running = true

func reset_cup():
	$Cup/Fill_Line.position.y = $Cup.size.y - targetCoffeeAmount - 16
	$Cup/Coffee.position.y = $Cup.size.y - 16
	$Cup/Coffee.size.y = 0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	if running:
		# If coffee is currently being pour, increase the current coffee amount based on pour speed
		if Input.is_action_pressed("ui_accept"):
			currentCoffeeAmount += pourSpeed * delta
			currentLabel.text = "Current: %.1f mL" % currentCoffeeAmount
			$Cup/Coffee.position.y = $Cup.size.y - currentCoffeeAmount - 16
			$Cup/Coffee.size.y = currentCoffeeAmount
		if !(Input.is_action_pressed("ui_accept")) && (currentCoffeeAmount > 0):
			_checkCoffeeAmount()
	else:
		if Input.is_key_pressed(KEY_E):
			close_game()

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
	reset_cup()

func close_game():
	get_parent().hide()
	_ready()
