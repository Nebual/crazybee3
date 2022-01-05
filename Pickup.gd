extends Node2D

enum PickupTypes {SCORE, HEALTH, BAD}
export var pickup_type = PickupTypes.SCORE

signal increment_score

var enemy = preload("res://Enemy.tscn")
var enemy_frog = preload("res://EnemyFrog.tscn")
var coin_sound = preload("res://music/coin.wav")

var main : Node2D
var anim_player: AnimationPlayer
var level : Node2D
var level_collision : CollisionShape2D
var player : Area2D
# Called when the node enters the scene tree for the first time.
func _ready():
	anim_player = get_node("AnimationPlayer")
	main = get_node("/root/Main")
	level = get_node("../") # Level
	level_collision = get_node("../Collision")
	player = get_node("/root/Main/Player")
	reset()

func reset():
	if pickup_type == PickupTypes.SCORE:
		anim_player.play("growing" + str(randi() % 4))
	if pickup_type == PickupTypes.HEALTH:
		anim_player.play("candy" + str(randi() % 4))
		position = get_random_pos_far_from_player()
	
func get_random_pos_far_from_player(min_distance: int = 150):
	var obstacles = get_tree().get_nodes_in_group("obstacles")
	var offset
	for _i in range(20):
		offset = Vector2(Util.rand_signed_float(0.8) * level_collision.shape.extents.x, Util.rand_signed_float(0.8) * level_collision.shape.extents.y)
		if !position_too_close(obstacles, min_distance, offset + level_collision.global_position):
			return offset # passes all checks, good spawn
	# fallback to _a_ spawn after 20 attempts
	return offset
func position_too_close(obstacles, min_distance: int, pos: Vector2) -> bool:
	var player_distance = (player.global_position).distance_to(pos)
	if player_distance < min_distance:
		return true
	var placeholder_shape = CircleShape2D.new()
	placeholder_shape.radius = 40
	var placeholder_transform = Transform2D(global_transform)
	placeholder_transform.origin = pos
	for ent in obstacles:
		var collision_shape = ent as CollisionShape2D
		if collision_shape:
			if collision_shape.shape.collide(collision_shape.global_transform, placeholder_shape, placeholder_transform):
				return true
		elif ent.global_position.distance_to(pos) < 70:
			return true
	return false

func relocate():
	position = get_random_pos_far_from_player() # lets reuse this pickup instead of making a new one
	reset()

func spawn_enemy():
	var new_enemy
	if randf() < 0.33:
		new_enemy = enemy_frog.instance()
	else:
		new_enemy = enemy.instance()
		if randf() < 0.25:
			new_enemy.type = "split"
		else:
			new_enemy.type = "regular"
	new_enemy.position = get_random_pos_far_from_player()
	level.add_child(new_enemy)

func maybe_spawn_health(chance: float = 0.25):
	if randf() < chance and len(get_tree().get_nodes_in_group("health_pickups")) < 1:
		var health_pickup = duplicate()
		health_pickup.pickup_type = PickupTypes.HEALTH
		health_pickup.add_to_group("health_pickups")
		level.add_child(health_pickup)

func increment_score():
	emit_signal("increment_score", 1)

func _on_Pickup_area_entered(area):
	if area.name != "Player": return # only Player collisions can activate pickups

	if pickup_type == PickupTypes.SCORE:
		increment_score()
		relocate()
		call_deferred("spawn_enemy") # by deferring this spawn until we're idle, it avoids a lagspike
		call_deferred("maybe_spawn_health")
		Util.play_sound(coin_sound, -20, 0, 1.25)
	elif pickup_type == PickupTypes.HEALTH:
		area.adjust_health(1)
		Util.play_sound(coin_sound, -10, 0, 0.7)
		queue_free()
