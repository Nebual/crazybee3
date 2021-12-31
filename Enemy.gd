extends RigidBody2D

export var damage = 1
export var min_speed = 100
export var max_speed = 300
export var type = "regular"

var times_split = 0
var original_velocity: Vector2
var last_direction: Vector2
var audio_player: AudioStreamPlayer2D
var split_texture = preload("res://sprites/ball_yellow.png")

func _ready():
	audio_player = $"AudioStreamPlayer2D"
	add_to_group("bombable")
	if type == "split":
		$"BallRed".texture = split_texture
	last_direction = Vector2(Util.rand_signed_float(3), Util.rand_signed_float(2)).normalized()
	linear_velocity = last_direction * (randf() * (max_speed - min_speed) + min_speed)
	original_velocity = linear_velocity

var age = 0
func _process(delta):
	age += delta
	var current_direction = linear_velocity.normalized()
	if current_direction != last_direction:
		audio_player.pitch_scale = 0.8 + (linear_velocity.length_squared() / 100000) * 0.5
		audio_player.play(0)
		last_direction = current_direction
		if type == "split" and age > 10:
			age = 0
			times_split = times_split + 1
			if times_split <= 2:
				$"BallRed".scale *= 0.85
				$"CollisionShape2D".scale *= 0.85
				
				var other = duplicate()
				other.times_split = times_split
				get_parent().add_child(other)
			else:
				queue_free()
