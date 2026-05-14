
extends Node

var current_language := "ro"

var translations := {
	"ro": {
		"greeting": "Bună ziua!",
		"start_game": "Începe jocul",
		"settings": "Setări"
	},
	"en": {
		"greeting": "Hello!",
		"start_game": "Start Game",
		"settings": "Settings"
	}
}

signal language_changed

func get_text(key: String) -> String:
	if translations[current_language].has(key):
		return translations[current_language][key]
	return key  # returnează cheia dacă nu găsește traducerea

func set_language(lang: String) -> void:
	if translations.has(lang):
		current_language = lang
		language_changed.emit()
