extends Control

@onready var hour_label: Label= $Hours
@onready var minute_label: Label = $Minutes

func _on_time_system_updated(date_time: DateTime):
	hour_label.text = str(date_time.hours)
	minute_label.text = str(date_time.minutes)
