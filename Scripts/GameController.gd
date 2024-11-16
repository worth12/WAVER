extends Node

@onready var clock = $"Clock Sprite"
@onready var dialogue_manager = $DialogueManager


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not has_node("DialogueManager"):
		var dialogue_manager_scene = preload("res://scenes/DialogueManager.tscn")
		var dialogue_manager_instance = dialogue_manager_scene.instantiate()
		add_child(dialogue_manager_instance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
