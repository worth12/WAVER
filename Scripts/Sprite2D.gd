extends Sprite2D

# Signal to detect mouse input
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and Dialogic.current_timeline == null:
		if get_global_mouse_position().distance_to(global_position) <= texture.get_size().x / 2:
			_on_sprite_clicked()

func _on_sprite_clicked():
	# Transition to a new scene
	$popup/Control._ready()
	$popup.show()
