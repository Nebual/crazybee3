extends Node2D

var ball_template: RigidBody2D

var ball: RigidBody2D
var spriteFrog: AnimatedSprite
var tongue: Line2D
var player: Node2D

func _ready():
	ball = $"Enemy"
	spriteFrog = $"StaticFrog/SpriteFrog"
	tongue = $"LineTongue"
	player = $"/root/Main/Player"
	$"StaticFrog".add_to_group("bombable")
	ball_template = ball.duplicate()


func _process(delta):
	if !is_instance_valid(ball): # ball died (eg. from collision)
		if is_instance_valid(spriteFrog):
			spriteFrog.animation = "angry"
			ball_template.min_speed += 150
			ball_template.max_speed += 200
			var new_ball = ball_template.duplicate()
			var flipped = -1 if spriteFrog.flip_h else 1
			new_ball.position = Vector2(28 * flipped, -16 + spriteFrog.frame * 4)
			add_child(new_ball)
			ball = new_ball
	if !is_instance_valid(spriteFrog): # frog died
		if is_instance_valid(tongue):
			tongue.queue_free()
		return
	
	spriteFrog.flip_h = player.global_position.x < spriteFrog.global_position.x
	var flipped = -1 if spriteFrog.flip_h else 1
	
	if is_instance_valid(tongue):
		tongue.points[0] = spriteFrog.position + Vector2(12 + 28 * flipped, -7 + spriteFrog.frame * 4)
		tongue.points[1] = ball.position + Vector2(11,5)
