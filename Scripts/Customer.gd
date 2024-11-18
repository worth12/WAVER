extends Node2D

@onready var minigame_controller = $MinigameController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not has_node("MinigameController"):
		var minigame_controller_scene: PackedScene = load("res://Scenes/MinigameController.tscn")
		var minigame_controller_instance: Node = minigame_controller_scene.instantiate()
		minigame_controller = minigame_controller_instance
		add_child(minigame_controller)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and Dialogic.current_timeline == null:
		if get_global_mouse_position().distance_to($CustomerSprite.global_position) <= $CustomerSprite.texture.get_size().x / 2:
			minigame_controller.spawn_minigame_sprites(["Coffee", "Foam", "Latte"])
