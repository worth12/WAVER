# GameController.gd
extends Node

@onready var dialogue_manager = $DialogueManager
@onready var minigame_controller = $MiniGames
@onready var clock = $Clock
@export var customers_per_day: int = 3  # Number of minigames per day
@export var minigames_per_customer: int = 3

var day_count: int = 0  # Current day count
var minigame_count: int = 0
var customer_count: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not has_node("DialogueManager"):
		var dialogue_manager_scene = preload("res://scenes/DialogueManager.tscn")
		var dialogue_manager_instance = dialogue_manager_scene.instantiate()
		add_child(dialogue_manager_instance)
	minigame_controller.connect("minigame_completed", Callable(self, "_on_minigame_completed"))

func _on_minigame_completed():
	minigame_count += 1
	print("Minigame completed! Total minigames today: %d" % minigame_count)
	
	if minigame_count == minigames_per_customer:
		customer_count += 1
		minigame_count = 0

	increment_clock()

	# Check if a new day should begin
	if customer_count == customers_per_day:
		start_new_day()

func start_new_day():
	day_count += 1
	minigame_count = 0
	customer_count = 0 # Reset for the new day
	start_dialog()
	print("New day started! Current day: %d" % day_count)

func increment_clock():
	# Increment the clock by a fixed amount
	clock.increment_time()
	print("Clock incremented!")
	# Add clock increment logic here (e.g., game_seconds in your Clock node)

func start_dialog():
	dialogue_manager.force_next_encounter()
