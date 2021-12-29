extends Node

# Hold onto this between rounds
var lastScoreName = ""

# Helper to disable some key bindings while typing
func is_typing() -> bool:
	var focus = $"/root/Main/GUI/DeathOverlay/GameOverBox/MarginContainer/VBox/VBoxContainer/ScoreName".get_focus_owner()
	if focus == null:
		return false
	# todo: may want to check the type of focus is actually a text input
	# print("In focus: ", focus.name)
	return true
