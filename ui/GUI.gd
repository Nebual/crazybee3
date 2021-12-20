extends Node2D

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		toggle_pause(!get_tree().paused)


func _on_Pickup_increment_score(amount):
	var score_amount = $"MarginContainer/VBoxContainer/ScoreLine/Amount"
	score_amount.text = str(int(score_amount.text) + amount)

func toggle_pause(state: bool):
	get_tree().paused = state
	var start: Button = $"MarginContainer/VBoxContainer/StartButton"
	start.disabled = !state
	var pause: Button = $"MarginContainer/VBoxContainer/Pause"
	pause.disabled = state

func _on_StartButton_pressed():
	toggle_pause(false)

func _on_PauseButton_pressed():
	toggle_pause(true)
