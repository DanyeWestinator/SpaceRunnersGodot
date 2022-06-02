extends Node2D
enum States {
	Play,
	Pause,
	MainMenu,
	Dead,
	ColorChooser
}

var screensize
var columns = { 1 : 0.16666, 2 : 0.33333, 3 : 0.5, 4 : 0.66666, 5 : 0.833333,}
export (Texture) var starTexture
export (bool) var DisplayColumns = false
var loaded = false
export (String, FILE, ".txt") var gameDataPath
var gamedata = {}
export (States) var currentState





# Called when the node enters the scene tree for the first time.
func _ready():
	#don't run if already loaded
	if (loaded == true):
		return
	#Sets the appropriate column spacing
	
	screensize = $Player/Camera.get_viewport_rect().size
	for column in columns:
		#sets the columns to their relative width
		var width = screensize.x

		var x = (width * columns[column]) 
		columns[column] = x
		
		#Whether to spawn the grid of stars that displays the grid
		if (DisplayColumns):
			var star = Sprite.new()
			star.texture = starTexture
			star.modulate = Color(0,0,1,1)
			star.scale = Vector2(25, 25)
			star.position.x = x
			star.position.y = $Player.position.y - screensize.y
			star.position.y = int(star.position.y)

			
			star.name = "Star" + str(column) + "-"+ str(star.position)#star.position
			call_deferred("add_child", star)
			
	#$Star.position = Vector2(columns[3], $Player.position.y - screensize.y)
	loaded = true
	ParseGameData()
	#print("Loaded game successfully")
	
func ParseGameData():

	var f = File.new()
	var basePath = "res://base_gamedata.txt"
	
	
	var lines = ""
	f.open(basePath, File.READ)
	#gets the default values
	while not f.eof_reached():
		var line = f.get_line()
		if line.strip_edges() != "":
			var split = line.split(":")
			gamedata[split[0]] = float(split[1])
		lines += line
	if f.file_exists(basePath) and f.file_exists(gameDataPath) == false:
		var temp = File.new()
		temp.open(gameDataPath, File.WRITE)
		#close it, then open a new one to edit
		temp.store_string(lines)
		temp.close()
		
	f.close()
	f = File.new()
		
	
	f.open(gameDataPath, File.READ)
	while not f.eof_reached():
		var line = f.get_line()
		if line == "":
			continue
		line = line.split(":")
		gamedata[line[0]] = float(line[1])
		#parse file here
		
	f.close()
	
	pass
func _on_Start_Button_released():
	currentState = States.Play
	reset()
	
func UpdateGameData():
	var file = ""
	for item in gamedata.keys():
		file += item + ":" + str(gamedata[item]) + "\n"
	var f = File.new()
	f.open(gameDataPath, File.WRITE)
	#print(gameDataPath)
	f.store_string(file)
	f.close()
func UpdateDataItem(name, val, update = true):
	#if not update, set
	if name in gamedata.keys() and update:
		gamedata[name] += val
	else:
		gamedata[name] = val
	UpdateGameData()

#Safe way to ask if an object exists. If not, creates it with val 0
func GetDataItem(item, default = 0):
	if item in gamedata.keys():
		return gamedata[item]
		
	gamedata[item] = default
	UpdateGameData()
	return gamedata[item]
func reset():
	$Player.reset()
	$AsteroidSpawner.reset()
	$BackgroundParent.reset()
	$EnemySpawner.reset()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	return



func _on_Restart_pressed():
	currentState = States.Play
	reset()

func _on_ColorChooser_pressed():
	if currentState == States.MainMenu:
		currentState = States.ColorChooser
	elif currentState == States.ColorChooser:
		currentState = States.MainMenu


func _on_MainMenu_button_up():
	currentState = States.MainMenu
	$Player/SpaceshipSprite.visible = true
	$Player/ThrustParticles.visible = true

