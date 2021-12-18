extends Node2D

var enemy = preload("res://Enemy.tscn")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_action_pressed("ui_accept"): #When you press Space or Enter
		var new_enemy = enemy.instance()
		new_enemy.position = get_node("Board/PlayArea/PlayAreaCollision").global_position
		new_enemy.linear_velocity = Vector2(300,200)
		add_child(new_enemy)
