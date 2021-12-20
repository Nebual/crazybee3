extends Node2D

var enemy = preload("res://Enemy.tscn")
export var start_paused = true

# Called when the node enters the scene tree for the first time.
func _ready():
	if start_paused:
		get_tree().paused = true

func _process(delta):
	if Input.is_action_pressed("ui_accept"): #When you press Space or Enter
		var new_enemy = enemy.instance()
		new_enemy.position = get_node("Board/PlayArea/PlayAreaCollision").global_position
		new_enemy.linear_velocity = Vector2(300,200)
		add_child(new_enemy)
