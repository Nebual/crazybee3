extends Area2D

signal health_changed
signal bombs_changed
export var speed = 400  # How fast the player will move (pixels/sec).
export var health = 3
export var bombs = 2
var screen_size  # Size of the game window.
var velocity = Vector2()  # The player's movement vector.

var pickup_scene = preload("res://Pickup.tscn")
var bomb_scene = preload("res://Bomb.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size

func wrap_around_board():
	var collision_shape: CollisionShape2D = get_node("/root/Main/Board/PlayArea/PlayAreaCollision")
	var playAreaMins = collision_shape.global_position - collision_shape.shape.extents
	var playAreaMaxs = collision_shape.global_position + collision_shape.shape.extents
	var player = get_node("CollisionShape2D")
	var playerSize = scale * player.shape.radius
	if position.x + playerSize.x < playAreaMins.x:
		#print("warp to right")
		position.x += collision_shape.shape.extents.x*2 + playerSize.x*2
	elif position.x - playerSize.x > playAreaMaxs.x:
		#print("warp to left")
		position.x -= collision_shape.shape.extents.x*2 + playerSize.x*2
	if position.y + playerSize.y < playAreaMins.y:
		#print("warp to bottom")
		position.y += collision_shape.shape.extents.y*2 + playerSize.y*2
	elif position.y - playerSize.y > playAreaMaxs.y:
		#print("warp to top")
		position.y -= collision_shape.shape.extents.y*2 + playerSize.y*2
	
func _process(delta):
	if health <= 0:
		if Input.is_action_just_pressed("restart"):
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
	
	if Input.is_action_just_pressed("ui_accept") and bombs > 0:
		adjust_bombs(-1)
		var bomb = bomb_scene.instance()
		bomb.position = position
		$"../".add_child(bomb)

	if velocity.x != 0:
		(get_node("Sprite_Bee") as AnimatedSprite).animation = "right" if velocity.x > 0 else "left"
		get_node("Shield/Sprite_Shield").animation = "right" if velocity.x > 0 else "left"
	elif velocity.y != 0:
		get_node("Sprite_Bee").animation = "down" if velocity.y > 0 else "up"
		get_node("Shield/Sprite_Shield").animation = "down" if velocity.y > 0 else "up"
	
	if Input.is_action_just_pressed("restart"):
		death()

func adjust_health(amount: int):
	health = clamp(health + amount, 0, 5)
	emit_signal("health_changed", health)

func adjust_bombs(amount: int):
	bombs = clamp(bombs + amount, 0, 5)
	emit_signal("bombs_changed", bombs)

func death():
	adjust_health(-health)
	
	var sprite = $"Sprite_Bee"
	sprite.animation = "idle"
	sprite.flip_v = true

func _on_Player_body_entered(body):
	if health <= 0:
		return
	if 'damage' in body: # hit a baddie
		adjust_health(-body.damage)
		(body as RigidBody2D).queue_free()
		if health == 0:
			death()
