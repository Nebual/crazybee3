extends Node2D

var score = 0

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		toggle_pause(!get_tree().paused)


func _on_Pickup_increment_score(amount):
	var score_amount = $"MarginContainer/VBoxContainer/ScoreLine/Amount"
	score += amount
	score_amount.text = str(score)

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


func _on_Player_health_changed(health: int):
	for amount in range(1,6):
		var health_sprite : AnimatedSprite = get_node("MarginContainer/VBoxContainer/Health/Health" + str(amount))
		health_sprite.visible = health >= amount


func _on_Player_bombs_changed(bombs: int):
	for amount in range(1,6):
		var sprite : AnimatedSprite = get_node("MarginContainer/VBoxContainer/Bombs/Bomb" + str(amount))
		sprite.visible = bombs >= amount
