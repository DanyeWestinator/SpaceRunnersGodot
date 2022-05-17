extends Sprite



export (float) var moveSpeed = 25


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.y -= (moveSpeed * delta)


func _on_Area2D_area_entered(area):
	#Ignore the player and other bolts
	if "Player" in area.name or "Bolt" in area.name:
		return
	if "AsteroidPrefab" in area.name:
		area.Die()
	
	self.queue_free()
	#print(area.name)
	pass # Replace with function body.
