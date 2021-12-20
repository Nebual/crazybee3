extends Node2D

enum PickupTypes {SCORE, BAD}
export var pickup_type = PickupTypes.SCORE

var enemy = preload("res://Enemy.tscn")

var sprite: AnimatedSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite = get_node("AnimatedSprite")
	reset()

func reset():
	sprite.animation = "flower" + str(randi() % 4)
	sprite.frame = 0

var timeObserved = 0
func _process(delta):
	timeObserved += delta
	if timeObserved > 1:
		timeObserved -= 1
		# once a second:
		if sprite.frame == 5:
			sprite.frame = 4

# eg. limit = 0.95 means you'll get a random number between -0.95 and 0.95
func rand_signed_float(limit):
	return (randf() * limit * 2) - limit
	
func get_random_pos_far_from_player(min_distance: int = 150):
	var play_area : CollisionShape2D = get_node("/root/Main/Board/PlayArea/PlayAreaCollision")
	var player : Area2D = get_node("/root/Main/Player")
	var distance = 0
	var new_pos
	while distance < min_distance:
		var offset = Vector2(rand_signed_float(0.95) * play_area.shape.extents.x, rand_signed_float(0.95) * play_area.shape.extents.y)
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
	get_node("/root/Main").add_child(new_enemy)

func increment_score():
	pass # todo

func _on_Pickup_area_entered(area):
	if area.name != "Player": return # only Player collisions can activate pickups

	if pickup_type == PickupTypes.SCORE:
		increment_score()
		relocate()
		spawn_enemy()
	# queue_free() # destroy self
