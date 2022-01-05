extends Node2D

signal next_level

var score = 0
var has_started = false

func _process(delta):
	if !Persistent.is_typing():
		if Input.is_action_just_pressed("pause"):
			toggle_pause(!get_tree().paused)
		elif get_tree().paused and Input.is_action_just_pressed("restart"):
			toggle_pause(false)


func _on_Pickup_increment_score(amount):
	var score_amount = $"MarginContainer/VBoxContainer/ScoreLine/Amount"
	score += amount
	score_amount.text = str(score)
	if score > 0 and score % 30 == 0:
		emit_signal("next_level")

func toggle_pause(state: bool):
	get_tree().paused = state
	var start: Button = $"MarginContainer/VBoxContainer/StartButton"
	start.disabled = !state
	var pause: Button = $"MarginContainer/VBoxContainer/Pause"
	pause.disabled = state
	if !has_started:
		has_started = true
		$"ControlsOverlay/AnimationPlayer".play("fade")

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


func _on_Player_death():
	var animation_player = $"DeathOverlay/AnimationPlayer"
	animation_player.play("fadein")
	$"DeathOverlay/GameOverBox/MarginContainer/VBox/VBoxContainer/ScoreSubmitButton".disabled = false
	$"DeathOverlay/GameOverBox/MarginContainer/VBox/VBoxContainer/ScoreName".text = Persistent.lastScoreName


func _on_DeathRestart_pressed():
	get_tree().reload_current_scene()




const SCOREBOARDS_BASE_URL = "https://gmanman.nebtown.info/scoreboards/"
func get_scoreboard_id():
	if OS.is_debug_build():
		return "crazybee-testing"
	return "crazybee-2022"
func submit_highscore(name, score):
	Persistent.lastScoreName = name
	var scoreboard_id = get_scoreboard_id()
	var url = SCOREBOARDS_BASE_URL + scoreboard_id + "/addScore"
	var query = {
		"name": name,
		"score": score,
		"imageData": Util.get_last_death_screenshot_data(),
	}
	var headers = ["Content-Type: application/json"]
	$"HTTPRequestScoreboard".request(url, headers, true, HTTPClient.METHOD_PUT, JSON.print(query))

func _on_ScoreSubmitButton_pressed():
	var name = $"DeathOverlay/GameOverBox/MarginContainer/VBox/VBoxContainer/ScoreName".text
	submit_highscore(name, score)
	$"DeathOverlay/GameOverBox/MarginContainer/VBox/VBoxContainer/ScoreSubmitButton".disabled = true

var score_lines = []
func populate_scoreboard(scoreboard):
	# clear old board
	for score_line in score_lines:
		score_line.queue_free()
	score_lines = []
	
	var scoreList = $"Scoreboard/MarginContainer/VBoxContainer/ScoreList"
	var rank = 0
	for score_record in scoreboard:
		rank += 1
		var score_line = HBoxContainer.new()
		
		var score_label = Label.new()
		score_label.text = "%2d: %3d %s" % [rank, score_record['score'], score_record['name'].substr(0, 13)]
		score_line.add_child(score_label)
		
		var time_label
		if 'imageLink' in score_record && score_record['imageLink']:
			time_label = LinkButton.new()
			time_label.underline = time_label.UNDERLINE_MODE_ALWAYS
			time_label.connect("pressed", self, "_on_scoreboard_image_clicked", [score_record['imageLink']])
		else:
			time_label = Label.new()
		time_label.text = score_record['datePST']
		#time_label.add_font_override("font", font_small)
		time_label.size_flags_horizontal = time_label.SIZE_EXPAND | time_label.SIZE_SHRINK_END
		score_line.add_child(time_label)
		
		scoreList.add_child(score_line)
		score_lines.append(score_line)

func _on_HTTPRequestScoreboard_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var scoreboard = JSON.parse(body.get_string_from_utf8()).result['scores']
		populate_scoreboard(scoreboard)
		$"Scoreboard".visible = true
	else:
		print("Scoreboard response: ", result, " ", response_code, ", body: ", body.get_string_from_utf8())

func _on_scoreboard_image_clicked(link):
	print("Link clicked: ", link)
	OS.shell_open(link)

func _on_HighScores_pressed():
	var scoreboard = $"Scoreboard"
	if scoreboard.visible: # toggle it off
		scoreboard.visible = false
	else:
		var scoreboard_id = get_scoreboard_id()
		var url = SCOREBOARDS_BASE_URL + scoreboard_id
		$"HTTPRequestScoreboard".request(url)


func _on_CloseScoreboard_pressed():
	var scoreboard = $"Scoreboard"
	scoreboard.visible = false
