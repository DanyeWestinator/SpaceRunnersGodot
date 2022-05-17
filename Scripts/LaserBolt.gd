extends Sprite



export (float) var moveSpeed = 25
var player
var gm
var target_x = -1
var tolerance
var TimeToMove


# Declare member variables here. Examples:
# var a = 2
# var b = "text"



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.y -= (moveSpeed * delta)
	if target_x != -1 and (abs(target_x - position.x) < tolerance):
		position.x = target_x
	else:
		position.x = lerp(position.x, target_x, TimeToMove)
	if position.y < player.position.y - 1500:
		self.queue_free()


func _on_Area2D_area_entered(area):
	#Ignore the player and other bolts
	if "Player" in area.name or "Bolt" in area.name:
		return
	if "AsteroidPrefab" in area.name:
		area.Die()
		player.currentAsteroidsDestroyed += 1
		gm.gamedata["asteroidsDestroyed"] += 1
		print("Asteroids desroyed: ", gm.gamedata["asteroidsDestroyed"])
	
	self.queue_free()
	#print(area.name)
	pass # Replace with function body.
