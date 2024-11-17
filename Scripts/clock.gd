extends Node2D

@export var time_start: int = 540       # Start time in minutes (e.g., 0 = 12:00 AM)
@export var time_end: int = 1020     # End time in minutes (e.g., 1440 = 12:00 AM next day)
@export var steps: int = 9            # Number of increments between start and end time

@onready var minute_hand = $MinuteHand
@onready var hour_hand = $HourHand

var current_step: int = 0             # Current step in the day
var total_minutes: int = 0            # Current time in minutes

func _ready():
	reset_clock()

func reset_clock():
	current_step = 0
	total_minutes = time_start
	update_clock_hands()

func increment_time():
	if current_step < steps:
		current_step += 1
		total_minutes = lerp(time_start, time_end, float(current_step) / steps)
		update_clock_hands()
	else:
		print("End of day reached!")  # Optional handling for end of day

func update_clock_hands():
	# Calculate angles
	var minute_angle = (total_minutes % 60) * 6  # Each minute = 6 degrees
	var hour_angle = (total_minutes / 60 % 12) * 30 + (minute_angle / 12)  # Minute contributes to hour hand

	# Apply rotations
	minute_hand.rotation_degrees = minute_angle
	hour_hand.rotation_degrees = hour_angle

	print("Clock updated: %d minutes (%d:%02d)" % [
		total_minutes,
		total_minutes / 60,
		total_minutes % 60
	])
