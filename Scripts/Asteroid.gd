extends Area2D

var RotateSpeed
var MoveSpeed

var y_bound
onready var gm = get_tree().root.get_child(0)


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if gm.currentState == gm.States.Play:
		if (position.y > y_bound + 10):
			get_node("..").Asteroids.erase(self)
			self.queue_free()
		
		position.y += (MoveSpeed * delta)
		rotation_degrees += (RotateSpeed * delta)
	
