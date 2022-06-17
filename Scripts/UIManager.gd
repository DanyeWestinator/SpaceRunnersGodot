extends Node2D

onready var gm = get_tree().root.get_child(0)
onready var player = get_node("..")

var baseTexts = {}

var lastState
var regex = RegEx.new()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (Array, Texture) var playPauseButtons

var isStatpage = false
var last_i = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	baseTexts[$IngameGUI/DistanceLabel] = $IngameGUI/DistanceLabel.text
	baseTexts[$IngameGUI/SpeedLabel] = $IngameGUI/SpeedLabel.text
	baseTexts[$IngameGUI/ShotsLeft] = $IngameGUI/ShotsLeft.text
	baseTexts[$IngameGUI/BoostsLeft] = $IngameGUI/BoostsLeft.text
	baseTexts[$DeathGUI/MaxDeathDistance] = $DeathGUI/MaxDeathDistance.text
	baseTexts[$Statpage/MaxDistance] = $Statpage/MaxDistance.text
	baseTexts[$Statpage/AsteroidCounter] = $Statpage/AsteroidCounter.text
	baseTexts[$Statpage/EnemyCounter] = $Statpage/EnemyCounter.text
	
	baseTexts[$Statpage/EnemyCounter] = $Statpage/EnemyCounter.text
	
	InitState(gm.currentState)
	
	lastState = gm.currentState

func InitState(state):
	if (state == gm.States.MainMenu):
		$MainMenuGUI.visible = true
		$PlayPause.visible = false
	if (state == gm.States.Play):
		$IngameGUI.visible = true
		$PlayPause.visible = true
		player.get_node("ShieldParticles").visible = true
	if (state == gm.States.Dead):
		$DeathGUI.visible = true
		if gm.gamedata.has("maxDistance") == false:
			gm.gamedata["maxDistance"] = 0.0
		var maxDistance = gm.gamedata["maxDistance"]
		var distanceText = baseTexts[$DeathGUI/MaxDeathDistance]

		if player.distanceTravelled > maxDistance:
			gm.gamedata["maxDistance"] = player.distanceTravelled
			gm.UpdateGameData()
			maxDistance = player.distanceTravelled
			distanceText += "\nNew Best!"
		distanceText = distanceText.replace("DIST", str(int(player.distanceTravelled)))
		distanceText = distanceText.replace("MAX", str(int(maxDistance)))
		$DeathGUI/MaxDeathDistance.text = distanceText
		var count = str(player.currentAsteroidsDestroyed)
		$DeathGUI/AsteroidsCounter.text = count
		$PlayPause.visible = false
	if (state == gm.States.Pause):
		$PlayPause/PlayPauseParent/Sprite.texture = playPauseButtons[1]
		$PlayPause/PauseGUI.visible = true
		
	if state == gm.States.ColorChooser:
		$ColorChooser.visible = true
		

func CloseState(state):
	if (state == gm.States.MainMenu):
		$MainMenuGUI.visible = false
	if state == gm.States.Play:
		$IngameGUI.visible = false
		player.get_node("ShieldParticles").visible = false
	if state == gm.States.Dead:
		$DeathGUI.visible = false
		$PlayPause.visible = false
	if state == gm.States.ColorChooser:
		$ColorChooser.visible = false
	if state == gm.States.Pause:
		$PlayPause/PlayPauseParent/Sprite.texture = playPauseButtons[0]
		$PlayPause/PauseGUI.visible = false
		_close_stats()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if lastState != gm.currentState:
		CloseState(lastState)
		InitState(gm.currentState)
	if gm.currentState == gm.States.Play:
		UpdateIngameGUI(gm.currentState)
	lastState = gm.currentState

func UpdateIngameGUI(_state):
	var distanceText = baseTexts[$IngameGUI/DistanceLabel].replace("0", str(int(player.distanceTravelled)))
	$IngameGUI/DistanceLabel.text = distanceText
	var speedText = baseTexts[$IngameGUI/SpeedLabel].replace("0", str(int(player.ForwardSpeed)))
	$IngameGUI/SpeedLabel.text = speedText
	var boostsString = "Boost: "
	
	for i in range(int(player.BoostTextLen * (float(player.timeSinceBoost) / player.BoostCooldown))):
		if i >= player.BoostTextLen:
			break
			print("too long?")
		boostsString += player.BoostChar

	$IngameGUI/BoostsLeft.text = boostsString
	$IngameGUI/ShotsLeft.text = baseTexts[$IngameGUI/ShotsLeft]
	for _i in range(int(player.currentShotTime / player.ShotRecharge)):
		$IngameGUI/ShotsLeft.text += player.ShotsChar
		
func UpdatePause():
	#print("Pause Updating!")
	if Input.is_action_just_pressed("primary_tap"):

		return
	var state = gm.currentState
	if state == gm.States.Play:
		gm.currentState = gm.States.Pause
	elif state == gm.States.Pause:
		_close_stats()
		gm.currentState = gm.States.Play

	



func _on_toggle_stats():
	if isStatpage == false:
		isStatpage = true

		$Statpage.visible = true
		var text = baseTexts[$Statpage/MaxDistance]
		text = text.replace("MAX", int(gm.GetDataItem("maxDistance")))
		$Statpage/MaxDistance.text = text
		text = baseTexts[$Statpage/AsteroidCounter]
		text = text.replace("0", int(gm.GetDataItem("asteroidsDestroyed")))
		$Statpage/AsteroidCounter.text = text
		text = baseTexts[$Statpage/EnemyCounter]
		text = text.replace("0", gm.GetDataItem("LifetimeShipsKilled"))
		$Statpage/EnemyCounter.text = text
	else:
		_close_stats()
	if gm.currentState == gm.States.Pause:
		if isStatpage:
			$PlayPause/PauseGUI/StatsToggle.text = "Close Stats"
		else:
			$PlayPause/PauseGUI/StatsToggle.text = "Open Stats"
func _close_stats():
	$Statpage.visible = false
	isStatpage = false
	$PlayPause/PauseGUI/StatsToggle.text = "Open Stats"
