class_name DateTime extends Resource


@export_range(0, 59) var seconds: int = 0
@export_range(0, 59) var minutes: int = 0
@export_range(0, 12) var hours: int = 8
@export_range(0, 14) var days: int = 0

var delta_time: float = 0

func increase_by_sec(delta_seconds: float) -> void:
	delta_time += delta_seconds
	if delta_time < 1:return
	
	var delta_int_secs: int = delta_time
	delta_time -= delta_int_secs
	
	seconds += delta_int_secs
	minutes += seconds / 60
	hours += minutes / 60
	days += hours / 24
	
	seconds = seconds % 60
	minutes = minutes % 60 
	hours = hours % 24
	
	if hours > 12:
		hours = 1
	if hours == 5:
		return
	print_debug(str(days) + ":" + str(hours) + ":" + str(minutes) + ":" + str(seconds))
