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

export (float) var maxShotChargeSize = 4

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var tts = timeToShoot
	currentShotTime = 0#timeToShoot * 0.7

func Die():
	gm.UpdateDataItem("LifetimeShipsKilled", 1)
	currentDestroyTime = 0
	$ShipSprite.visible = false
	$ThrustParticles.visible = false
	$DeathParticles.emitting = true
	$EnemyArea.queue_free()
	$FirePoints.visible = false

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
	_update_shot_size()
	if currentDestroyTime >= 0:
		currentDestroyTime += delta
		if currentDestroyTime >= destroyDelay:
			clearShots()
			self.queue_free()
func clearShots():
	var blank = 0
	var i = 0
	for shot in shots:
		if weakref(shot).get_ref():
			i += 1
			shot.queue_free()
		else:
			blank += 1
	#print(i, " shots cleared, ", blank, " blanks")
	shots = []
func _update_shot_size():
	var scale = currentShotTime / timeToShoot * maxShotChargeSize
	if gm.currentState != gm.States.Play:
		scale = 0
	scale = Vector2(scale, scale)
	
	$FirePoints/Left/BoltCharge.scale = scale
	$FirePoints/Right/BoltCharge.scale = scale
	
func _on_EnemyArea_area_entered(area):
	if "Player" in area.name and gm.currentState == gm.States.Play:
		Die()
func Shoot():
	for i in range($FirePoints.get_child_count()):
		#print($FirePoints/Left/BoltCharge.global_position, "\t", player.global_position, "\t", global_position)
		var bolt = laserPrefab.instance()
		var pos = $FirePoints.get_child(i).global_position
		#pos = self.global_position - pos
		shots.append(bolt)
		bolt.Create(gm, player, pos, laserBoltSpeed,
		laserBoltScale, laserBoltColor, -1)
		bolt.firedBy = "Enemy"
		bolt.gm = gm
		$FirePoints/Left/ShotParticles.emitting = true
		$FirePoints/Right/ShotParticles.emitting = true
