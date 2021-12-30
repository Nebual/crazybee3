extends AnimatedSprite

export var blast_radius = 500
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	for ent in get_tree().get_nodes_in_group("bombable"):
		if (ent as Node2D).global_position.distance_to(global_position) < blast_radius:
			ent.queue_free()
		elif "original_velocity" in ent:
			ent.linear_velocity = ent.original_velocity
