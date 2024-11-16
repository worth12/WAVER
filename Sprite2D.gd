extends Sprite2D

# Signal to detect mouse input
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_on_sprite_clicked()

func _on_sprite_clicked():
	# Transition to a new scene
	get_tree().change_scene("PUT MINIGAME SCENE HERE")
