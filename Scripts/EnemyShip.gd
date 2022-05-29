extends Node2D

export (float) var timeToShoot = .3
var currentShotTime = 0

var destroyDelay = 3
var currentDestroyTime = -1
var player
var laserPrefab = load("res://Scenes/LaserBolt.tscn")
var shots = []
onready var gm = get_tree().root.get_child(0)
var laserBoltSpeed
var laserBoltColor
var laserBoltScale
var i

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var tts = timeToShoot
	currentShotTime = 0#timeToShoot * 0.7
	print(currentShotTime, "\t" , tts)

func Die():
	currentDestroyTime = 0
	$ShipSprite.visible = false
	$ThrustParticles.visible = false
	$DeathParticles.emitting = true
	$EnemyArea.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if gm.currentState == gm.States.Pause:
		return
	if player.nextColumn == i:
		currentShotTime += delta
	else:
		currentShotTime = 0
	if currentShotTime >= timeToShoot and currentDestroyTime < 0 and gm.currentState == gm.States.Play:
		currentShotTime = 0
		Shoot()
	
	if currentDestroyTime >= 0:
		currentDestroyTime += delta
		if currentDestroyTime >= destroyDelay:
			clearShots()
			self.queue_free()
func clearShots():
	for shot in shots:
				if weakref(shot).get_ref():
					shot.queue_free()

func _on_EnemyArea_area_entered(area):
	if "Player" in area.name and gm.currentState == gm.States.Play:
		Die()
func Shoot():
	for i in range($FirePoints.get_child_count()):
		var bolt = laserPrefab.instance()
		var pos = $FirePoints.get_child(i).global_position
		pos = self.global_position - pos
		shots.append(bolt)
		bolt.Create(gm, player, pos, laserBoltSpeed,
		laserBoltScale, laserBoltColor, -1)
		bolt.firedBy = "Enemy"
		#$FirePoints.add_child(bolt)
		#add_child(bolt)
		#bolt.global_position = $FirePoints.get_child(i).global_position
		#bolt.position = $FirePoints.get_child(i).position
		#bolt.player = player

