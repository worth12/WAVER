extends Control

@export var speed: float = 1.0  # Speed of the bar movement
var direction: int = 1         # Direction of movement (1 or -1)
var progress_value: float = 0  # Current value of the ProgressBar

var green_zone_start: float = 40  # Adjust based on your green zone's position
var green_zone_end: float = 60    # Adjust based on your green zone's position

signal success  # Signal for a successful hit
signal failure  # Signal for a miss

func _process(delta):
	# Update the progress value
	progress_value += direction * speed * delta

	# Reverse direction if it hits the edges
	if progress_value >= 100:
		direction = -1
	elif progress_value <= 0:
		direction = 1

	# Update the ProgressBar value
	$ProgressBar.value = progress_value
	
func _input(event):
	if event.is_action_pressed("ui_accept"):  # Replace with your action name
		check_hit()

func check_hit():
	if (green_zone_start <= progress_value) && (progress_value <= green_zone_end):
		emit_signal("success")
		print("Success!")  # Add your success logic here
	else:
		emit_signal("failure")
		print("Miss!")  # Add your failure logic here

func _on_success():
	$Label.text = "Great Timing!"
	$Label.modulate = Color(0, 1, 0)  # Green

func _on_failure():
	$Label.text = "Too Bad!"
	$Label.modulate = Color(1, 0, 0)  # Red
