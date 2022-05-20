extends Sprite

var player
export (float) var MoveSpeed = 15


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.y += (MoveSpeed * delta)
	if position.distance_to(player.position) >= 1500:
		self.queue_free()


func _on_BoltCollider_area_entered(area):
	if "Player" in area.name:
		area.Die()
		self.queue_free()
	if "Asteroid" in area.name:
		area.Die()
		print("Enemy hit asteroid")
