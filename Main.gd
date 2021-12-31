extends Node2D

var enemy = preload("res://Enemy.tscn")
export var start_paused = true

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize() # Randomizes the seed of the random number generator
	if start_paused:
		get_tree().paused = true
	if !OS.has_feature("standalone"):
		$"AudioStreamPlayer".volume_db = -50

func _process(delta):
	pass
