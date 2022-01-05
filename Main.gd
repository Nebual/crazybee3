extends Node2D

var enemy = preload("res://Enemy.tscn")
export var start_paused = true
export var current_level = 1

var play_area : Node2D
var levels = []
var changing_level = false

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize() # Randomizes the seed of the random number generator
	if start_paused:
		get_tree().paused = true
	if !OS.has_feature("standalone"):
		$"AudioStreamPlayer".volume_db = -50
	play_area = $"PlayArea"
	levels.append($"PlayArea/Level")
	levels.append($"PlayArea/Level2")
	update_active_level()

const LEVEL_CHANGE_SPEED = 100
func update_active_level():
	for i in len(levels):
		var level: Node2D = levels[i]
		var enabled = ((i+1) == current_level) or (changing_level and (i+2) == current_level)
		if enabled:
			if !levels[i].owner:
				play_area.add_child(level)
			level.add_to_group("level")
		else:
			if levels[i].owner:
				play_area.remove_child(level)
			level.remove_from_group("level")
func next_level():
	if !changing_level and current_level < len(levels):
		current_level += 1
		changing_level = true
		update_active_level()
		levels[current_level - 1].position.x = 700
		levels[current_level - 2].constant_linear_velocity.x = -LEVEL_CHANGE_SPEED
		levels[current_level - 1].constant_linear_velocity.x = -LEVEL_CHANGE_SPEED

func _process(delta):
	if OS.is_debug_build() and Input.is_key_pressed(KEY_T) and not changing_level:
		next_level()
func _physics_process(delta):
	if changing_level:
		levels[current_level - 2].position.x -= LEVEL_CHANGE_SPEED * delta
		levels[current_level - 1].position.x -= LEVEL_CHANGE_SPEED * delta
		if levels[current_level - 1].position.x < 0:
			levels[current_level - 1].position.x = 0
			levels[current_level - 1].constant_linear_velocity.x = 0
			changing_level = false
			update_active_level()


func _on_next_level():
	next_level()
