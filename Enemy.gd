extends RigidBody2D

export var damage = 1
export var min_speed = 200
export var max_speed = 400

var original_velocity: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("bombable")
	original_velocity = linear_velocity


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
