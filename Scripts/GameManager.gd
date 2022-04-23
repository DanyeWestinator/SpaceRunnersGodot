extends Node2D
enum States {
	Play,
	Pause,
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
			add_child(star)
			
	#$Star.position = Vector2(columns[3], $Player.position.y - screensize.y)
	loaded = true
	ParseGameData()
func ParseGameData():
	var f = File.new()
	f.open(gameDataPath, File.READ)
	while not f.eof_reached():
		var line = f.get_line().split(":")
		gamedata[line[0]] = float(line[1])
		#parse file here
		
	f.close()
	
	pass
func UpdateGameData():
	var file = ""
	for item in gamedata.keys():
		file += item + ":" + str(gamedata[item])
	var f = File.new()
	f.open(gameDataPath, File.WRITE)
	f.store_string(file)
	f.close()
	
func reset():
	$Player.position = Vector2.ZERO
	$AsteroidSpawner.reset()
	$BackgroundParent.reset()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	return

