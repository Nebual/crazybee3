extends Area2D

signal health_changed
signal bombs_changed
signal death
export var speed = 400  # How fast the player will move (pixels/sec).
export var health = 3
export var bombs = 2
var screen_size  # Size of the game window.
var velocity = Vector2()  # The player's movement vector.

var pickup_scene = preload("res://Pickup.tscn")
var bomb_scene = preload("res://Bomb.tscn")

var sound_player : AudioStreamPlayer
var sound_player2 : AudioStreamPlayer
var play_area: Area2D
var play_area_collision: CollisionShape2D
var speech: Label

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	sound_player = $"SoundPlayer"
	sound_player2 = $"SoundPlayer2"
	play_area = get_node("/root/Main/Board/PlayArea")
	play_area_collision = get_node("/root/Main/Board/PlayArea/PlayAreaCollision")
	speech = $"Speech"

func wrap_around_board():
	var playAreaMins = play_area_collision.global_position - play_area_collision.shape.extents
	var playAreaMaxs = play_area_collision.global_position + play_area_collision.shape.extents
	var player = get_node("CollisionShape2D")
	var playerSize = scale * player.shape.radius
	if position.x + playerSize.x < playAreaMins.x:
		#print("warp to right")
		position.x += play_area_collision.shape.extents.x*2 + playerSize.x*2
	elif position.x - playerSize.x > playAreaMaxs.x:
		#print("warp to left")
		position.x -= play_area_collision.shape.extents.x*2 + playerSize.x*2
	if position.y + playerSize.y < playAreaMins.y:
		#print("warp to bottom")
		position.y += play_area_collision.shape.extents.y*2 + playerSize.y*2
	elif position.y - playerSize.y > playAreaMaxs.y:
		#print("warp to top")
		position.y -= play_area_collision.shape.extents.y*2 + playerSize.y*2
	
func _process(delta):
	if health <= 0:
		if Input.is_action_just_pressed("restart") and !Persistent.is_typing():
			get_tree().reload_current_scene()
		return
	if Input.is_action_pressed("ui_right"):
		velocity = Vector2(1, 0)
	if Input.is_action_pressed("ui_left"):
		velocity = Vector2(-1, 0)
	if Input.is_action_pressed("ui_down"):
		velocity = Vector2(0,1)
	if Input.is_action_pressed("ui_up"):
		velocity = Vector2(0,-1)
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		get_node("Shadow/AnimatedSprite").play()
		get_node("Sprite_Bee").play()
		get_node("Shield/Sprite_Shield").play()
	position += velocity * delta
	wrap_around_board()
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_node("Shield").visible = !get_node("Shield").visible
		
		if get_node("Shield").collision_layer == 0b100:		#Is Shield on Layer 3?
			get_node("Shield").collision_layer = 0b000		#Then set to 0
		else:
			get_node("Shield").collision_layer = 0b100		#Else set to 3
		
		print("Collision Layer: ",get_node("Shield").collision_layer)
		print("Is Visible: ",get_node("Shield").is_visible())
	
	if Input.is_action_just_pressed("ui_home") and bombs > 0:
		adjust_bombs(-1)
		var bomb = bomb_scene.instance()
		bomb.position = global_position - play_area.global_position
		play_area.add_child(bomb)
		for ent in get_tree().get_nodes_in_group("bombable"): #Slow all enemies after dropping bomb
			if "linear_velocity" in ent:
				ent.linear_velocity /= 4

	if velocity.x != 0:
		(get_node("Sprite_Bee") as AnimatedSprite).animation = "right" if velocity.x > 0 else "left"
		get_node("Shield/Sprite_Shield").animation = "right" if velocity.x > 0 else "left"
	elif velocity.y != 0:
		get_node("Sprite_Bee").animation = "down" if velocity.y > 0 else "up"
		get_node("Shield/Sprite_Shield").animation = "down" if velocity.y > 0 else "up"
	
	if Input.is_action_just_pressed("restart"):
		death()
		
	if Input.is_action_just_pressed("ui_accept"):
		jump()
	
	display_pressed_numbers()

func adjust_health(amount: int):
	health = clamp(health + amount, 0, 5)
	emit_signal("health_changed", health)

func adjust_bombs(amount: int):
	bombs = clamp(bombs + amount, 0, 5)
	emit_signal("bombs_changed", bombs)


var numbers_queue = []
func display_pressed_numbers():
	for i in range(10):
		if Input.is_key_pressed(KEY_0 + i) or Input.is_key_pressed(KEY_KP_0 + i):
			var num_recently_pressed = false
			for pair in numbers_queue:
				if pair[0] == i and (OS.get_ticks_msec() - pair[1]) < 250:
					num_recently_pressed = true
					break
			if !num_recently_pressed:
				numbers_queue.append([i, OS.get_ticks_msec()])
	if len(numbers_queue):
		speech.text = ""
		var new_numbers_queue = []
		for pair in numbers_queue:
			var num = pair[0]
			var time = pair[1]
			if (OS.get_ticks_msec() - time) < 1000:
				speech.text += str(num)
				new_numbers_queue.append(pair)
		numbers_queue = new_numbers_queue

var death_sound = preload("res://music/death.tres")
var hurt_sound = preload("res://music/sad.wav")
var murloc_sound = preload("res://music/murloc.tres")
var jump_sound = preload("res://music/jump2.wav")
var jump_state = ""

func play_sound(channel, sound, volume=0, offset=0):
	var chosen_sound_player = sound_player2 if channel == 2 else sound_player
	chosen_sound_player.stream = sound
	chosen_sound_player.volume_db = volume
	chosen_sound_player.play(offset)

func jump():
	jump_state = "up"
	$"JumpTimer1".start()
	$"JumpTimer2".start()
	play_sound(1, jump_sound, -20)
	
func _on_JumpTimer1_timeout():
	if jump_state == "up":
		$"Sprite_Bee".scale += Vector2(0.06,0.06)
		$"Sprite_Bee".position.y -= 8
		$"Shadow/AnimatedSprite".scale -= Vector2(0.05,0.05)
	elif jump_state == "down" and $"Sprite_Bee".scale > Vector2(2,2):
		$"Sprite_Bee".scale -= Vector2(0.06,0.06)
		$"Sprite_Bee".position.y += 8
		$"Shadow/AnimatedSprite".scale += Vector2(0.05,0.05)
	elif $"Sprite_Bee".scale <= Vector2(2,2):
		$"Sprite_Bee".scale = Vector2(2,2)
		jump_state = ""
func _on_JumpTimer2_timeout():
	jump_state = "down"

func death():
	adjust_health(-health)
	play_sound(1, death_sound)
	
	var sprite = $"Sprite_Bee"
	sprite.animation = "idle"
	sprite.flip_v = true
	emit_signal("death")
	get_node("Shadow/AnimatedSprite").stop()
	get_node("Shadow/AnimatedSprite").position.y = -14 #Move shadow underneath our fallen hero

func _on_Player_body_entered(body):
	if health <= 0:
		return
	if jump_state != "":
		return
	if 'damage' in body: # hit a baddie
		adjust_health(-body.damage)
		if body.name == "StaticFrog":
			play_sound(2, murloc_sound, -5, 0.4)
		(body as Node2D).queue_free()
		if health == 0:
			death()
		else:
			play_sound(1, hurt_sound)

