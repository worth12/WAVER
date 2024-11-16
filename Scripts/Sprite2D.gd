extends Sprite2D

# Signal to detect mouse input
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_on_sprite_clicked()

func _on_sprite_clicked():
	# Transition to a new scene
	print("wow")
	$popup.show()
