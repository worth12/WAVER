# MinigameController.gd
extends Node

signal minigame_completed(minigame_name: String, score: int)  # Signal to propagate to GameController

func spawn_minigame_sprite(minigame_sprite: Sprite2D):
	add_child(minigame_sprite)
	minigame_sprite.connect("minigame_completed", Callable(self, "_on_minigame_completed"))

func _on_minigame_completed(minigame_name: String, score: int):
	print("MinigameController: Minigame completed!")
	emit_signal("minigame_completed", minigame_name, score)  # Propagate to GameController
