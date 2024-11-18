extends Node

var current_encounter_index = 0
var dialogic_timeline_started = false

var encounter_order = [
	"initial_setup",
	"cat1",
	"cow1",
	"bunny1",
	"turtle1",
	"cat2",
	"cow2",
	"bunny2",
	"turtle2",
	"cat3",
	"cat4",
	"cow3",
	"bunny3",
	"turtle3",
	"cow4",
	"bunny4",
	"game_ending"
]

func _ready():
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	force_next_encounter() # begin initial setup

func start_next_encounter():
	if current_encounter_index < encounter_order.size():
		var timeline_name = encounter_order[current_encounter_index]
		print("Starting timeline: ", timeline_name)
		
		Dialogic.start(timeline_name)
		dialogic_timeline_started = true
		
		current_encounter_index += 1
	else:
		print("All encounters completed!")

func _on_timeline_ended():
	dialogic_timeline_started = false
	if current_encounter_index >= encounter_order.size():
		print("All encounters completed, transitioning to game over!")
		get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")

	
func force_next_encounter():
	if not dialogic_timeline_started:
		start_next_encounter()

func get_current_encounter() -> String:
	if current_encounter_index < encounter_order.size():
		return encounter_order[current_encounter_index]
	return ""

func has_completed_encounter(encounter_name: String) -> bool:
	var encounter_index = encounter_order.find(encounter_name)
	return encounter_index < current_encounter_index and encounter_index != -1
