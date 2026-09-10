extends Node
signal level_up(new_level)
var current_level: int = 1
const LEVEL_THRESHOLDS = [
	 5,
	15,
	30,
	50,
	75,
	100,
	130,
	165,
	200,
	235,
	270,
	305,
	330,
	355,
	380
]


func get_level(activities: int) -> int:
	var level = 1
	for i in range(LEVEL_THRESHOLDS.size()):
		if activities >= LEVEL_THRESHOLDS[i]:
			level = i + 1
		else:
			break
	return level


func get_progress(activities: int) -> float:
	var level = get_level(activities)
	if level >= 15:
		return 100.0
	var current_threshold = LEVEL_THRESHOLDS[level - 1]
	var next_threshold = LEVEL_THRESHOLDS[level]
	return float(activities - current_threshold) / float(next_threshold - current_threshold) * 100.0

func set_current_level(activities: int):
	current_level = get_level(activities)

func check_level_up(activities: int):
	var new_level = get_level(activities)
	if new_level > current_level:
		current_level = new_level
		level_up.emit(new_level)
