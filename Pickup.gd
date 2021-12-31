extends Node2D

enum PickupTypes {SCORE, HEALTH, BAD}
export var pickup_type = PickupTypes.SCORE

signal increment_score

var enemy = preload("res://Enemy.tscn")
var enemy_frog = preload("res://EnemyFrog.tscn")
var coin_sound = preload("res://music/coin.wav")

var main : Node2D
var anim_player: AnimationPlayer
var play_area : CollisionShape2D
var player : Area2D
# Called when the node enters the scene tree for the first time.
func _ready():
	anim_player = get_node("AnimationPlayer")
	main = get_node("/root/Main")
	play_area = get_node("/root/Main/Board/PlayArea/PlayAreaCollision")
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
		offset = Vector2(Util.rand_signed_float(0.8) * play_area.shape.extents.x, Util.rand_signed_float(0.8) * play_area.shape.extents.y)
		if !position_too_close(obstacles, min_distance, offset + play_area.global_position):
			return offset # passes all checks, good spawn
	# fallback to _a_ spawn after 20 attempts
	return offset
func position_too_close(obstacles, min_distance: int, pos: Vector2) -> bool:
	var player_distance = (player.global_position).distance_to(pos)
	if player_distance < min_distance:
		print("player ", player.global_position, " too close to ", pos)
		return true
	for ent in obstacles:
		if ent.global_position.distance_to(pos) < 70:
			print("ent ", ent.global_position, " too close to ", pos)
			return true
		print("ent ", ent.global_position, " far enough away from ", pos)
	return false

func relocate():
	position = get_random_pos_far_from_player() # lets reuse this pickup instead of making a new one
	reset()

func spawn_enemy():
	var new_enemy = enemy_frog.instance() if randf() < 0.33 else enemy.instance()
	new_enemy.position = get_random_pos_far_from_player()
	play_area.add_child(new_enemy)

func maybe_spawn_health(chance: float = 0.25):
	if randf() < chance and len(get_tree().get_nodes_in_group("health_pickups")) < 1:
		var health_pickup = duplicate()
		health_pickup.pickup_type = PickupTypes.HEALTH
		health_pickup.add_to_group("health_pickups")
		play_area.add_child(health_pickup)

func increment_score():
	emit_signal("increment_score", 1)

func _on_Pickup_area_entered(area):
	if area.name != "Player": return # only Player collisions can activate pickups

	if pickup_type == PickupTypes.SCORE:
		increment_score()
		relocate()
		call_deferred("spawn_enemy") # by deferring this spawn until we're idle, it avoids a lagspike
		Util.play_sound(coin_sound, -20, 0, 1.25)
		maybe_spawn_health()
	elif pickup_type == PickupTypes.HEALTH:
		area.adjust_health(1)
		Util.play_sound(coin_sound, -10, 0, 0.7)
		queue_free()
