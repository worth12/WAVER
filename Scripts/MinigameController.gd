# MinigameController.gd
extends Node2D

@export var t1: Texture2D
@export var t2: Texture2D
@export var t3: Texture2D

@onready var textures = [t1,t2,t3]
var textures_count: int = 0

@onready var customer = $Customer

signal minigame_completed(minigame_name: String, score: int)  # Signal to propagate to GameController

func spawn_minigame_sprite(minigame_sprite: Sprite2D):
	add_child(minigame_sprite)
	minigame_sprite.connect("minigame_completed", Callable(self, "_on_minigame_completed"))

func _on_minigame_completed(minigame_name: String, score: int):
	print("MinigameController: Minigame completed!")
	emit_signal("minigame_completed", minigame_name, score)  # Propagate to GameController
	if minigame_name == "pouring":
		$Customer/popup2.show()
	elif minigame_name == "foam":
		$Customer/popup3.show()

func _ready():
	# Connect the pressed signal to a custom function
	customer.connect("pressed", Callable(self, "_on_texture_button_pressed"))

# Function that gets called when the button is pressed
func _on_texture_button_pressed():
	$Customer/popup1.show()



func new_customer():
	var texture_normal
	# Load a PNG texture
	var new_texture = load("res://Assets/8445773.png") as Texture2D

	# Check if the texture loaded correctly
	if new_texture:
		texture_normal = new_texture  # Assign it to the TextureButton
		print("Texture successfully assigned!")
	else:
		print("Failed to load texture")
	# Convert to Texture2D if necessary
	$Customer.texture = texture_normal.decompress()
	textures_count +=1
	if textures_count > 2:
		textures_count = 0
	
