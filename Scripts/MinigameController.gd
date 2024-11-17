# MinigameController.gd
extends Node

signal minigame_completed  # Signal to propagate to GameController

func spawn_minigame_sprite(minigame_sprite: Sprite2D):
	add_child(minigame_sprite)
	minigame_sprite.connect("minigame_completed", Callable(self, "_on_minigame_completed"))

func _on_minigame_completed():
	print("MinigameController: Minigame completed!")
	emit_signal("minigame_completed")  # Propagate to GameController
