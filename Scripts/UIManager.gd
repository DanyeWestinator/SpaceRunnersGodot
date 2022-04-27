extends Node2D

onready var gm = get_tree().root.get_child(0)
onready var player = get_node("..")

var baseTexts = {}

var lastState
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	baseTexts[$IngameGUI/DistanceLabel.name] = $IngameGUI/DistanceLabel.text
	baseTexts[$IngameGUI/SpeedLabel.name] = $IngameGUI/SpeedLabel.text
	baseTexts[$IngameGUI/BoostsLeft.name] = $IngameGUI/BoostsLeft.text
	baseTexts[$DeathGUI/MaxDistance.name] = $DeathGUI/MaxDistance.text
	InitState(gm.currentState)
	
	lastState = gm.currentState

func InitState(state):
	if (state == gm.States.MainMenu):
		$MainMenuGUI.visible = true
	if (state == gm.States.Play):
		$IngameGUI.visible = true
	if (state == gm.States.Dead):
		$DeathGUI.visible = true
		if gm.gamedata.has("maxDistance") == false:
			gm.gamedata["maxDistance"] = 0.0
		var maxDistance = gm.gamedata["maxDistance"]
		var distanceText = baseTexts[$DeathGUI/MaxDistance.name]
		if player.distanceTravelled > maxDistance:
			gm.gamedata["maxDistance"] = player.distanceTravelled
			gm.UpdateGameData()
			maxDistance = player.distanceTravelled
			distanceText += "\nNew Best!"
		distanceText = distanceText.replace("DIST", str(int(player.distanceTravelled)))
		distanceText = distanceText.replace("MAX", str(int(maxDistance)))
		$DeathGUI/MaxDistance.text = distanceText
		

func CloseState(state):
	if (state == gm.States.MainMenu):
		$MainMenuGUI.visible = false
	if state == gm.States.Play:
		$IngameGUI.visible = false
	if state == gm.States.Dead:
		$DeathGUI.visible = false
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if lastState != gm.currentState:
		CloseState(lastState)
		InitState(gm.currentState)
	if gm.currentState == gm.States.Play:
		UpdateIngameGUI(gm.currentState)
	lastState = gm.currentState

func UpdateIngameGUI(state):
	var distanceText = baseTexts["DistanceLabel"].replace("0", str(int(player.distanceTravelled)))
	$IngameGUI/DistanceLabel.text = distanceText
	var speedText = baseTexts["SpeedLabel"].replace("0", str(player.ForwardSpeed))
	$IngameGUI/SpeedLabel.text = speedText
	var boostsString = "Boost: "
	if player.isBoosting == false:
		for i in range(player.BoostTextLen):
			boostsString += player.BoostChar
	else:
		for i in range(int(player.BoostTextLen * (float(player.currentBoostTime) / player.BoostTime))):
			boostsString += player.BoostChar
	$IngameGUI/BoostsLeft.text = boostsString
	pass
