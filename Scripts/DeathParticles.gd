extends CPUParticles2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export (float) var timeToDeath = 2.0
var currentDeathTimer = 0
var timedDestroy = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if timedDestroy:
		currentDeathTimer += delta
	if currentDeathTimer >= timeToDeath:

		self.queue_free()
