extends Node2D

func _animate_clock_face():
	# Example: Glow the clock face during work hours
	if hours >= 9 and hours < 17:
		$ClockSprite.modulate = Color(1, 1, 1, 1)  # Fully visible
	else:
		$ClockSprite.modulate = Color(0.5, 0.5, 0.5, 1)  # Dimmed


func _on_time_system_updated():
	pass # Replace with function body.
