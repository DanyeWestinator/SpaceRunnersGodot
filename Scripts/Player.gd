extends Area2D
signal Hitbox

onready var gm = get_node("..")
export (float) var TimeToMove
export (Color) var ShipColor
export (float) var _tolerance = 0.1
var screensize


var columns
var currentColumn = 3
var nextColumn
export (bool) var UpButtonSpeedUp = true
export (float) var ForwardSpeed = 2
export (float) var DistanceScalar = 1
var distanceTravelled = 0

var baseDistanceLabel = ""
var baseSpeedLabel = ""
var baseMaxDistanceLabel = ""

var lastPos = position
var PAUSED = false

export (int) var BoostTextLen = 5
export (int) var BoostScale = 4
export (float) var BoostTime = 1
export (float) var BoostCooldown = 2
export (String) var BoostChar = ">"
var currentBoostTime = 0
var isBoosting = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#gets the game manager
	gm = get_node("..")
	#inits the game manager
	gm._ready()
	columns = gm.columns
	screensize = gm.screensize
	
	#Colors the ship, turns on thrust anim
	$SpaceshipSprite.modulate = ShipColor
	
	#$ThrustAnimation.show()
	#$ThrustAnimation.play()
	position.x = columns[3]
	#position.y = 0
	
	nextColumn = currentColumn
	
	baseDistanceLabel = $Labels/DistanceLabel.text
	baseSpeedLabel = $Labels/SpeedLabel.text
	baseMaxDistanceLabel = $DeathLabels/MaxDistance.text

	lastPos = position
	

	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (PAUSED == false):
		if Input.is_action_just_pressed("move_left") and nextColumn > 1:
			nextColumn -= 1
		if Input.is_action_just_pressed("move_right") and nextColumn < columns.size():
			nextColumn += 1
		if (Input.is_action_just_pressed("move_up") and isBoosting == false):
			UpdateSpeed(BoostScale)
			isBoosting = true
		if (Input.is_action_just_pressed("move_down") and false):
			if (UpButtonSpeedUp):
				UpdateSpeed(0.5)
			else:
				position.y += 50
		if Input.is_action_just_pressed("ui_cancel"):
			PAUSED = true
	elif (PAUSED == true):
		if Input.is_action_just_pressed("ui_cancel"):
			PAUSED = false

	BoostLogic(delta)
	#calls the movement logic
	move(delta)
	#updates GUI
	UpdateLabels()
	
	lastPos = position
func BoostLogic(delta):
	if isBoosting:
		currentBoostTime += delta
	if currentBoostTime >= BoostTime:
		isBoosting = false
		currentBoostTime = 0
		UpdateSpeed((1.0 / BoostScale)) 
	
	
func move(delta) -> void:
	
	#every frame, decreases y by Speed * delta
	position.y -= (ForwardSpeed * delta)
	
	#calculate distance from last position after movement
	#update distance travelled var
	var distance = abs(position.distance_to(lastPos))
	distance /= DistanceScalar
	distanceTravelled += distance
	
	
	
	#Moves the ship side to side
	var target = columns[nextColumn]
	if (abs(target - position.x) < _tolerance):
		currentColumn = nextColumn
		position.x = target
	else:
		position.x = lerp(position.x, target, TimeToMove)
	return
	#Changes forward position
	distanceTravelled += (ForwardSpeed * delta)
	position.y += (ForwardSpeed * delta)
	$Labels/Temp.text = str(position)
func UpdateSpeed(delta):
	ForwardSpeed *= delta
	$"./ThrustParticles/ThrustParticlesLeft".amount *= delta
	$"./ThrustParticles/ThrustParticlesRight".amount *= delta
	
func UpdateLabels():
	#updates the speed and distance travelled labels
	#also anything else later goes here
	var distanceText = baseDistanceLabel.replace("0", str(int(distanceTravelled)))
	$Labels/DistanceLabel.text = distanceText
	var speedText = baseSpeedLabel.replace("0", str(ForwardSpeed))
	$Labels/SpeedLabel.text = speedText
	var boostsString = "Boost: "
	if isBoosting == false:
		for i in range(BoostTextLen):
			boostsString += BoostChar
	else:
		for i in range(int(BoostTextLen * (float(currentBoostTime) / BoostTime))):
			boostsString += BoostChar
	$Labels/BoostsLeft.text = boostsString
	#$Labels/Temp.text = "(" + str(int(global_position.x)) + ", " + str(int(global_position.y)) + ")"


func _on_Player_area_entered(area):
	print("Hit the spaceship!")
	Die()

func Die():
	$SpaceshipSprite.visible = false
	$ThrustParticles.visible = false
	$DeathParticleExplosion.emitting = true
	$DeathLabels.visible = true
	var maxDistance = gm.gamedata["maxDistance"]
	if distanceTravelled > maxDistance:
		gm.gamedata["maxDistance"] = distanceTravelled
		gm.UpdateGameData()
	var distanceText = baseMaxDistanceLabel
	distanceText = distanceText.replace("DIST", str(int(distanceTravelled)))
	distanceText = distanceText.replace("MAX", str(int(maxDistance)))
	$DeathLabels/MaxDistance.text = distanceText
	get_node("../AsteroidSpawner").SpawnAsteroids = false
	$Labels.visible = false
	
	ForwardSpeed = 0
