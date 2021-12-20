extends Area2D

export var speed = 400  # How fast the player will move (pixels/sec).
var screen_size  # Size of the game window.
var velocity = Vector2()  # The player's movement vector.

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	
func _process(delta):
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
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_node("Shield").visible = !get_node("Shield").visible
		
		if get_node("Shield").collision_layer == 0b100:		#Is Shield on Layer 3?
			get_node("Shield").collision_layer = 0b000		#Then set to 0
		else:
			get_node("Shield").collision_layer = 0b100		#Else set to 3
		
		print("Collision Layer: ",get_node("Shield").collision_layer)
		print("Is Visible: ",get_node("Shield").is_visible())

	if velocity.x != 0:
		(get_node("Sprite_Bee") as AnimatedSprite).animation = "right" if velocity.x > 0 else "left"
		get_node("Shield/Sprite_Shield").animation = "right" if velocity.x > 0 else "left"
	elif velocity.y != 0:
		get_node("Sprite_Bee").animation = "down" if velocity.y > 0 else "up"
		get_node("Shield/Sprite_Shield").animation = "down" if velocity.y > 0 else "up"
		

	





# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Player_area_exited(area):
	if area.name == "PlayArea": # Bee has left the area
		var collision_shape = area.get_node("PlayAreaCollision")
		var player = get_node("CollisionShape2D")
		if velocity.x < 0:
			position.x += collision_shape.shape.extents.x*2 \
			 + player.shape.radius*2*scale.x
		if velocity.x > 0:
			position.x -= collision_shape.shape.extents.x*2 \
			 + player.shape.radius*2*scale.x
		if velocity.y < 0:
			position.y += collision_shape.shape.extents.y*2 \
			 + player.shape.radius*2*scale.y
		if velocity.y > 0:
			position.y -= collision_shape.shape.extents.y*2 \
			 + player.shape.radius*2*scale.y
