extends Node2D

enum PickupTypes {SCORE, BAD}
export var pickup_type = PickupTypes.SCORE

signal increment_score

var enemy = preload("res://Enemy.tscn")

var main : Node2D
var sprite: AnimatedSprite
var anim_player: AnimationPlayer
var play_area : CollisionShape2D
var player : Area2D
# Called when the node enters the scene tree for the first time.
func _ready():
	sprite = get_node("AnimatedSprite")
	anim_player = get_node("AnimationPlayer")
	main = get_node("/root/Main")
	play_area = get_node("/root/Main/Board/PlayArea/PlayAreaCollision")
	player = get_node("/root/Main/Player")
	reset()

func reset():
	anim_player.play("growing" + str(randi() % 4))

# eg. limit = 0.95 means you'll get a random number between -0.95 and 0.95
func rand_signed_float(limit):
	return (randf() * limit * 2) - limit
	
func get_random_pos_far_from_player(min_distance: int = 150):
	var distance = 0
	var new_pos
	while distance < min_distance:
		var offset = Vector2(rand_signed_float(0.8) * play_area.shape.extents.x, rand_signed_float(0.8) * play_area.shape.extents.y)
		new_pos = play_area.global_position + offset
		distance = player.global_position.distance_to(new_pos)
	return new_pos

func relocate():
	global_position = get_random_pos_far_from_player() # lets reuse this pickup instead of making a new one
	reset()

func spawn_enemy():
	var new_enemy = enemy.instance()
	new_enemy.position = get_random_pos_far_from_player()
	new_enemy.linear_velocity = Vector2(rand_signed_float(300), rand_signed_float(200))
	main.add_child(new_enemy)

func increment_score():
	emit_signal("increment_score", 1)

func _on_Pickup_area_entered(area):
	if area.name != "Player": return # only Player collisions can activate pickups

	if pickup_type == PickupTypes.SCORE:
		increment_score()
		relocate()
		spawn_enemy()
	# queue_free() # destroy self
