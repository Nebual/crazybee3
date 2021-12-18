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
	pass # Replace with function body.
	
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
		$AnimatedSprite.play()
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	





# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Player_area_exited(area):
	if area.name == "PlayArea": # Bee has left the area
		var collision_shape = area.get_node("PlayAreaCollision")
		var player = get_node("CollisionShape2D")
		if velocity.x < 0:
			position.x += collision_shape.shape.extents.x*2\
			 + player.shape.radius*2*scale.x
		if velocity.x > 0:
			position.x -= collision_shape.shape.extents.x*2\
			 + player.shape.radius*2*scale.x
		if velocity.y < 0:
			position.y += collision_shape.shape.extents.y*2\
			 + player.shape.radius*2*scale.y
		if velocity.y > 0:
			position.y -= collision_shape.shape.extents.y*2\
			 + player.shape.radius*2*scale.y
