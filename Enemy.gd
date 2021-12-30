extends RigidBody2D

export var damage = 1
export var min_speed = 100
export var max_speed = 300

var original_velocity: Vector2
var last_direction: Vector2
var audio_player: AudioStreamPlayer2D

func _ready():
	audio_player = $"AudioStreamPlayer2D"
	add_to_group("bombable")
	last_direction = Vector2(Util.rand_signed_float(3), Util.rand_signed_float(2)).normalized()
	linear_velocity = last_direction * (randf() * (max_speed - min_speed) + min_speed)
	original_velocity = linear_velocity


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var current_direction = linear_velocity.normalized()
	if current_direction != last_direction:
		audio_player.pitch_scale = 0.8 + (linear_velocity.length_squared() / 100000) * 0.5
		audio_player.play(0)
		last_direction = current_direction
