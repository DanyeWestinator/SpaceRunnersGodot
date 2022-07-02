extends Sprite



export (float) var moveSpeed = 25
var player
var gm
var target_x = -1
var tolerance
var TimeToMove
var hit = false

var firedBy = "Player"
var direction = 1




# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func Create(_gm, _player, global_pos, speed,
 boltScale, color, direction = 1):
	self.gm = _gm
	self.scale = boltScale
	gm.add_child(self)
	self.player = _player
	self.direction = direction
	global_position = global_pos
	moveSpeed = speed
	self.modulate = color
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if gm.currentState == gm.States.Pause:
		return
	position.y -= (moveSpeed * delta * direction)
	if target_x != -1 and (abs(target_x - position.x) < tolerance):
		position.x = target_x
	elif target_x != -1:
		position.x = lerp(position.x, target_x, TimeToMove)
	if position.distance_to(player.position) >= 1500:
		self.queue_free()
	#if position.y < player.position.y - 1500:
		


func _on_Area2D_area_entered(area):
	#Ignore the player and other bolts
	if firedBy in area.name or "Bolt" in area.name:
		return
	if hit == true:
		return
	if "AsteroidPrefab" in area.name:
		if area.destroyedBy == "" and "Enemy" in firedBy:
			gm.UpdateDataItem("AsteroidsDestroyedByEnemy", 1)
			print("Enemy blew up asteroid")
		area.destroyedBy = firedBy
		area.Die()
		
		if "Player" in firedBy:
			player.currentAsteroidsDestroyed += 1
		

	elif "Enemy" in area.name and ("Enemy" in firedBy) == false:
		area.get_node("..").Die()
		player.currentEnemiesDestroyed += 1
	if "Player" in area.name and "Enemy" in firedBy:
		area.Die()
	hit = true
	self.queue_free()
	
