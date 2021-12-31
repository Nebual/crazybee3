extends StaticBody2D

export var damage = 1

var ball_template: RigidBody2D

var ball: RigidBody2D
var spriteFrog: AnimatedSprite
var tongue: Line2D
var player: Node2D
var animation_player: AnimationPlayer
var fraction: Node
var answer: int
var murloc_sound = preload("res://music/murloc.tres")
var pickup_sound = preload("res://music/pickup.wav")
var muted = false

func _ready():
	ball = $"../Enemy"
	spriteFrog = $"SpriteFrog"
	tongue = $"LineTongue"
	player = $"/root/Main/Player"
	add_to_group("bombable")
	ball_template = ball.duplicate()
	animation_player = $"AnimationPlayer"
	animation_player.play("default")
	fraction = $"FractionContainer/Fraction"
	if global_position.y < 150:
		$"FractionContainer".margin_top = 50
	var fraction_parts = gen_fraction()
	$"FractionContainer/Fraction/Numerator".text = str(fraction_parts[0])
	$"FractionContainer/Fraction/Denominator".text = str(fraction_parts[1])
	answer = fraction_parts[2]

func gen_fraction():
	var answer = randi() % 8 + 2
	while true:
		var denominator = randi() % 50
		var numerator = answer * denominator
		if numerator < 100:
			return [numerator, denominator, answer]

func _process(delta):
	if !is_instance_valid(ball): # ball died (eg. from collision)
		animation_player.play("angry")
		ball_template.min_speed += 150
		ball_template.max_speed += 200
		var new_ball = ball_template.duplicate()
		var flipped = -1 if spriteFrog.flip_h else 1
		new_ball.position = Vector2(28 * flipped, -16 + spriteFrog.frame * 4)
		$"../".add_child(new_ball)
		ball = new_ball
	if Input.is_key_pressed(KEY_0 + answer) || Input.is_key_pressed(KEY_KP_0 + answer):
		Util.play_sound(pickup_sound, -20, 0, 0.3)
		muted = true
		$"../".queue_free()
		return
	
	spriteFrog.flip_h = player.global_position.x < spriteFrog.global_position.x
	var flipped = -1 if spriteFrog.flip_h else 1
	
	if is_instance_valid(tongue):
		tongue.points[0] = spriteFrog.position + Vector2(12 + 28 * flipped, -7 + spriteFrog.frame * 4)
		tongue.points[1] = ball.position + Vector2(11,5)

func queue_free():
	if !muted:
		Util.play_sound(murloc_sound, 0, 0.4)
	.queue_free()
