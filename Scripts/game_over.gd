extends Control

@onready var pouring_score_label = $ScorePanel/PouringScore
@onready var foam_score_label = $ScorePanel/FoamScore
@onready var art_score_label = $ScorePanel/ArtScore
@onready var total_score_label = $ScorePanel/TotalScore
@onready var rating_label = $ScorePanel/RatingLabel

func _ready():
	var performanceFolder = Dialogic.VAR.get("player").get("performance")
	
	var pouring_score = performanceFolder.get("pouring_score")
	var pouring_max = performanceFolder.get("pouring_max_score")
	var foam_score = performanceFolder.get("foam_score")
	var foam_max = performanceFolder.get("foam_max_score")
	var art_score = performanceFolder.get("art_score")
	var art_max = performanceFolder.get("art_max_score")
	
	var total_score = performanceFolder.get("total_score")
	var total_max = performanceFolder.get("total_max_score")
	var performance_percent = performanceFolder.get("performance_percent")
	
	# Update labels
	pouring_score_label.text = "Coffee Pouring Accuracy: %d / %d" % [pouring_score, pouring_max]
	foam_score_label.text = "Foam Quality Rating: %d / %d" % [foam_score, foam_max]
	art_score_label.text = "Latte Art Evaluation: %d / %d" % [art_score, art_max]
	total_score_label.text = "Overall Performance: %.1f%%" % performance_percent
	
	# Set rating text and color based on performance
	if performance_percent >= 80:
		rating_label.text = "Outstanding Performance! Mittens would be proud."
		rating_label.add_theme_color_override("font_color", Color(0, 1, 0))
	elif performance_percent >= 50:
		rating_label.text = "Acceptable results, but room for improvement."
		rating_label.add_theme_color_override("font_color", Color(1, 1, 0))
	else:
		rating_label.text = "Significant training required. Consider reviewing proper coffee protocols."
		rating_label.add_theme_color_override("font_color", Color(1, 0, 0))
