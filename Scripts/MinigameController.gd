# MinigameController.gd
extends Node

@export var coffee_position: Vector2 = Vector2(1000,400)
@export var coffee_texture: Texture = load("res://Assets/8445773.png")
@export var foam_position: Vector2 = Vector2(1000,600)
@export var foam_texture: Texture = load("res://Assets/8445903.png")
@export var latte_position: Vector2 = Vector2(1000,800)
@export var latte_texture: Texture = load("res://Assets/8445922.png")

signal minigame_completed_details(minigame_name: String, score: int)  # Signal to propagate to GameController

func spawn_minigame_sprites(minigames: Array):
	for minigame in minigames:
		match minigame:
			"Coffee":
				spawn_sprite(coffee_position, coffee_texture, "Coffee")
			"Foam":
				spawn_sprite(foam_position, foam_texture, "Foam")
			"Latte":
				spawn_sprite(latte_position, latte_texture, "Latte")

func _on_minigame_completed(minigame_name: String, score: int):
	print("MinigameController: Minigame completed!")
	match minigame_name:
		"Coffee":
			if has_node("Coffee"):
				$Coffee.queue_free()
		"Foam":
			if has_node("Foam"):
				$Foam.queue_free()
		"Latte":
			if has_node("Lattee"):
				$Latte.queue_free()
		
	emit_signal("minigame_completed_details", minigame_name, score)  # Propagate to GameController
	
	
func spawn_sprite(position: Vector2, texture: Texture, name: String):
	var sprite = Sprite2D.new()  # Create a new Sprite2D instance
	sprite.position = position   # Set the position
	sprite.texture = texture  # Load and assign the texture
	var script = load("res://Scripts/Sprite2D.gd")  # Load the script
	sprite.set_script(script)  # Attach the script to the sprite
	sprite.name = name
	add_child(sprite)  # Add the sprite to the current scene
	return sprite
