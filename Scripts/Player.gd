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
var startPlayerPos = Vector2.ZERO
var startVelocity
var PAUSED = false

export (int) var BoostTextLen = 5
export (int) var BoostScale = 4
export (float) var BoostTime = 1
export (float) var BoostCooldown = 2
export (String) var BoostChar = ">"
export (Color) var boostBaseColor = Color(0, 0, 1, 1)
export (Color) var boostColor = Color(1, 1, 0, 1)
export (Array, Color) var boostChargingColor = [Color(1, 1, 1, 1)]
export (int) var BoostParticleSubdivisions = 5
var maxBoostParticleAmount
var lastBoost_i = 0
var currentBoostTime = 0
var timeSinceBoost = 0
var isBoosting = false

#Speed increases every so often
export (float) var timeToSpeedup = 15
var currentSpeedupTime = 0
export (float) var speedupScale = 1.1

export (float) var minSwipeDistance = 25
var swipe_start = null

## ShotsVariables
export (float) var laserMoveSpeed = 25
export (Vector2) var laserScale = Vector2(6, 48)
export (Color) var laserColor = Color(1, 0, 0)
export (String) var ShotsChar = "X"
export (int) var MaxShots = 3
export (float) var ShotRecharge = 1
var currentShotTime
var currentAsteroidsDestroyed = 0
var currentEnemiesDestroyed = 0 

# Called when the node enters the scene tree for the first time.
func _ready():
	#gets the game manager
	gm = get_node("..")
	#inits the game manager
	gm._ready()
	columns = gm.columns
	screensize = gm.screensize
	#print(ShipColor.g)
	ShipColor = Color(gm.gamedata["colorR"], gm.gamedata["colorG"], gm.gamedata["colorB"])
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
	startPlayerPos = position
	startVelocity = ForwardSpeed
	currentShotTime = ShotRecharge * MaxShots
	maxBoostParticleAmount = $ShieldParticles.amount
	

func _unhandled_input(event):
	#handling swipe logic
	if event is InputEventScreenTouch:
		if event.pressed:
		  swipe_start = event.get_position()
		else:
			var dir = event.get_position() - swipe_start
			#ignore small swipes
			var abs_dir = dir.abs()
			#ignore small swipes
			if abs_dir.x < minSwipeDistance and abs_dir.y < minSwipeDistance:
				return
			dir = dir.normalized()
			abs_dir = dir.abs()
			if dir == Vector2.ZERO:
				return
			
			if abs_dir.x > abs_dir.y:
				if dir.x < 0:
					_on_Left_pressed()
				elif dir.x > 0:
					_on_Right_pressed()
			else:
				#Since going up on the screen is a negative y
				if dir.y < 0:
					_on_Boost_pressed()
		 
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if gm.currentState == gm.States.Pause:
		return
	if Input.is_action_just_pressed("move_left"):
		_on_Left_pressed()
		#nextColumn -= 1
	if Input.is_action_just_pressed("move_right"):
		_on_Right_pressed()
		#nextColumn += 1
	if Input.is_action_just_pressed("move_up"):
		_on_Boost_pressed()
		#UpdateSpeed(BoostScale)
		#isBoosting = true
	if Input.is_action_just_pressed("primary_tap"):
		_shoot()
	

	BoostLogic(delta)
	#calls the movement logic
	move(delta)
	
	
	if currentShotTime < (MaxShots * ShotRecharge):
		currentShotTime += delta
	if currentShotTime > (MaxShots * ShotRecharge):
		currentShotTime = MaxShots * ShotRecharge
	
	for i in range(3):
		var left = int(currentShotTime / ShotRecharge)
		$ShotCharge.get_child(i).visible = (i < left and gm.currentState == gm.States.Play)
		

	
	lastPos = position
	
	currentSpeedupTime += delta
	#don't speed up if boosting or not playing
	if currentSpeedupTime >= timeToSpeedup and isBoosting == false and gm.currentState == gm.States.Play:
		currentSpeedupTime = 0
		UpdateSpeed(speedupScale)
	
func BoostLogic(delta):
	timeSinceBoost += delta
	if isBoosting:
		currentBoostTime += delta
	var size = boostChargingColor.size()
	var i = int(size * (float(timeSinceBoost) / BoostCooldown))
	if i > size:
		i = size
	if i != lastBoost_i:
		var count = float(i) / size
		count = int(count * float(maxBoostParticleAmount))
		if count == 0 and isBoosting == false:
			count = 1
		$ShieldParticles.amount = count

		if i == size:
			$ShieldParticles.color = boostBaseColor
		elif isBoosting == false:
			$ShieldParticles.color = boostChargingColor[i]
		#print("new c is ", count)
	lastBoost_i = i
	#end boost logic
	if currentBoostTime >= BoostTime:
		timeSinceBoost = 0
		isBoosting = false
		currentBoostTime = 0
		UpdateSpeed((1.0 / BoostScale))
		$ShieldParticles.color = boostChargingColor[0]
		$ShieldParticles.amount = 1

	
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
	print("old label update")
	#updates the speed and distance travelled labels
	#also anything else later goes here
	var distanceText = baseDistanceLabel.replace("0", str(int(distanceTravelled)))
	$Labels/DistanceLabel.text = distanceText
	var speedText = baseSpeedLabel.replace("0", str(ForwardSpeed))
	$Labels/SpeedLabel.text = speedText
	var boostsString = "Boost: "
	if isBoosting == false:
		for _i in range(BoostTextLen):
			boostsString += BoostChar
	else:
		for i in range(int(BoostTextLen * (float(currentBoostTime) / BoostTime))):
			boostsString += BoostChar
	$Labels/BoostsLeft.text = boostsString
	#$Labels/Temp.text = "(" + str(int(global_position.x)) + ", " + str(int(global_position.y)) + ")"

func _on_Player_area_entered(area):
	if isBoosting and ("Bolt" in area.name) == false:
		var explosion = load("res://Scenes/DeathParticles.tscn").instance()
		explosion.timedDestroy = true
		$BoostExplosions.add_child(explosion)
		explosion.position = Vector2.ZERO
		explosion.emitting = true
		explosion.visible = true
		if "Enemy" in area.name:
			explosion.color = area.get_node("../ShipSprite").modulate
			currentEnemiesDestroyed += 1
		elif "Asteroid" in area.name:

			explosion.color = area.get_child(0).modulate
			currentAsteroidsDestroyed += 1
		else:
			explosion.color = area.modulate
	if ("Bolt" in area.name):
		return
	if isBoosting and "Asteroid" in area.name:
		area.Die()
		return
	Die()

func Die():
	#Can't die if already dead
	if (gm.currentState != gm.States.Play or isBoosting):
		return
	gm.currentState = gm.States.Dead
	$SpaceshipSprite.visible = false
	$ThrustParticles.visible = false
	$DeathParticleExplosion.emitting = true
	$Hitbox.disabled = true
	$ShotCharge.visible = false
	#get_node("../AsteroidSpawner").SpawnAsteroids = false
	
	
	ForwardSpeed = startVelocity

func reset():

	position = startPlayerPos
	lastPos = position
	distanceTravelled = 0.0
	currentAsteroidsDestroyed = 0
	currentEnemiesDestroyed = 0
	$SpaceshipSprite.visible = true
	$ThrustParticles.visible = true
	ForwardSpeed = startVelocity
	currentShotTime = ShotRecharge * MaxShots
	$Hitbox.disabled = false
	$ShotCharge.visible = true
	currentShotTime = ShotRecharge * MaxShots
	timeSinceBoost = BoostCooldown
	nextColumn = 3
	$UIManager/IngameGUI/Right.visible = true
	$UIManager/IngameGUI/Left.visible = true

func _on_Left_pressed():
	if gm.currentState == gm.States.Play:
		if nextColumn > 1:
			nextColumn -= 1
			#if we move left, make sure the right is visible
			#$UIManager/IngameGUI/Right.paused = false
			$UIManager/IngameGUI/Right.visible = true
		if nextColumn == 1:
			$UIManager/IngameGUI/Left.visible = false
			#$UIManager/IngameGUI/Left.paused = true

func _on_Right_pressed():
	if gm.currentState == gm.States.Play:
		if nextColumn < columns.size():
			nextColumn += 1
			$UIManager/IngameGUI/Left.visible = true
		if nextColumn == columns.size():
			$UIManager/IngameGUI/Right.visible = false

func _on_Boost_pressed():
	if gm.currentState == gm.States.Play:
		if isBoosting == false and timeSinceBoost >= BoostCooldown:
			timeSinceBoost = 0
			UpdateSpeed(BoostScale)
			isBoosting = true
			$ShieldParticles.amount = maxBoostParticleAmount * 2
			$ShieldParticles.color = boostColor
	
func _on_color_pressed(extra_arg_0):
	ShipColor = extra_arg_0
	$SpaceshipSprite.modulate = ShipColor
	gm.UpdateDataItem("colorR", ShipColor.r, false)
	gm.UpdateDataItem("colorG", ShipColor.g, false)
	gm.UpdateDataItem("colorB", ShipColor.b, false)
	#gm.gamedata["colorR"] = ShipColor.r
	#gm.gamedata["colorG"] = ShipColor.g
	#gm.gamedata["colorB"] = ShipColor.b
	#gm.UpdateGameData()
	
func _shoot():
	
	if currentShotTime < ShotRecharge or gm.currentState != gm.States.Play:
		return
	
	currentShotTime -= ShotRecharge
	
	var bolt = load("res://Scenes/LaserBolt.tscn").instance()
	bolt.Create(gm, self, $ShootPoint.global_position,
	laserMoveSpeed * ForwardSpeed, laserScale, laserColor)
	
	bolt.target_x = columns[nextColumn]
	bolt.tolerance = _tolerance
	bolt.TimeToMove = TimeToMove
	
	if isBoosting:
		bolt.moveSpeed /= BoostScale

