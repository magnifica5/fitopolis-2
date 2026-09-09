extends Node
signal level_up(new_level)
var current_level: int = 1
const LEVEL_THRESHOLDS = [
	0,       # Level 1
	500,     # Level 2
	1500,    # Level 3
	3000,    # Level 4
	5000,    # Level 5
	7000,    # Level 6
	9500,    # Level 7
	12000,   # Level 8
	15000,   # Level 9
	18000,   # Level 10
	21500,   # Level 11
	25000,   # Level 12
	28500,   # Level 13
	32000,   # Level 14
	36000    # Level 15
]


func get_level(stars: int) -> int:
	var level = 1
	for i in range(LEVEL_THRESHOLDS.size()):
		if stars >= LEVEL_THRESHOLDS[i]:
			level = i + 1
		else:
			break
	return level


func get_progress(stars: int) -> float:
	var level = get_level(stars)
	if level >= 15:
		return 100.0
	var current_threshold = LEVEL_THRESHOLDS[level - 1]
	var next_threshold = LEVEL_THRESHOLDS[level]
	return float(stars - current_threshold) / float(next_threshold - current_threshold) * 100.0

func set_current_level(stars: int):
	current_level = get_level(stars)

func check_level_up(stars: int):
	var new_level = get_level(stars)
	if new_level > current_level:
		current_level = new_level
		level_up.emit(new_level)
