extends Node2D

# Clock hands
@onready var hour_hand = $HourHand
@onready var minute_hand = $MinuteHand

# Update the clock every frame
func _process(delta):
	# Get the current time
	var time = OS.get_time()

	# Calculate angles for each hand
	var second_angle = lerp(0, 360, time.second / 60.0)
	var minute_angle = lerp(0, 360, (time.minute + time.second / 60.0) / 60.0)
	var hour_angle = lerp(0, 360, (time.hour % 12 + time.minute / 60.0) / 12.0)

	# Apply rotations to the hands
	minute_hand.rotation_degrees = minute_angle
	hour_hand.rotation_degrees = hour_angle
