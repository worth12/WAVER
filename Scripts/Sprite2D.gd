extends Sprite2D

# Signal to detect mouse input
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and Dialogic.current_timeline == null:
		if get_global_mouse_position().distance_to(global_position) <= texture.get_size().x / 2:
			_on_sprite_clicked(self.name)

func _on_sprite_clicked(name: String):
	var popup_window: Window = Window.new()
	popup_window.size = Vector2(300, 200)
	popup_window.title = "Popup Window"
	popup_window.position = Vector2(1536,800)
	var scene_path: String = get_minigame_path(name)
	var scene: PackedScene = load(scene_path)
	var new_node: Node = scene.instantiate()
	new_node.name = name
	popup_window.add_child(new_node)  # Add it to the container
	add_child(popup_window)

func get_minigame_path(name: String) -> String:
	match name:
		"Coffee":
			return "res://Scenes/Coffee.tscn"
		"Foam":
			return "res://Scenes/Foam.tscn"
		"Latte":
			return "res://Scenes/latte_art.tscn"
	return ""
