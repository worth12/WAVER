extends Sprite2D

# Signal to detect mouse input
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if get_global_mouse_position().distance_to(global_position) <= texture.get_size().x / 2:
			_on_sprite_clicked()

func _on_sprite_clicked():
	# Transition to a new scene
	$popup/LatteArtGame._ready()
	$popup.show()