extends Node

var AsteroidPrefab = load("res://Scenes/AsteroidPrefab.tscn")
export (Array, Texture) var AsteroidTextures
export (Array, Color) var AsteroidColors
export (Vector2) var AsteroidDelay = Vector2(0.5, 2)
export (Vector2) var AsteroidSpeed = Vector2(25, 50)
export (float) var AsteroidRotateSpeed = 25
export (Vector2) var AsteroidScale = Vector2(1, 4)
onready var columns = get_node("..").columns
onready var screensize = get_node("..").screensize
var printed = false
var Asteroids = []
var random = RandomNumberGenerator.new()

var currentTime = 0
var maxTime



func _ready():
	maxTime = random.randf_range(AsteroidDelay.x, AsteroidDelay.y)

func SpawnAsteroid():
	#initializes the asteroid
	var asteroid = AsteroidPrefab.instance()
	#error check for screensize existing
	if (screensize == null):
		screensize = get_node("..").screensize
	#Sets asteroid transform
	asteroid.y_bound = screensize.y
	
	var scale = random.randf_range(AsteroidScale.x, AsteroidScale.y)
	asteroid.scale = Vector2(scale, scale)
	asteroid.position.y = -25
	var x = random.randi_range(1, columns.size())
	x = columns[x]
	asteroid.position.x = x
	
	#sets asteroid variables
	asteroid.MoveSpeed = random.randf_range(AsteroidSpeed.x, AsteroidSpeed.y)
	asteroid.RotateSpeed = random.randf_range(-1 * AsteroidRotateSpeed, AsteroidRotateSpeed)
	asteroid.get_node("Sprite").modulate = AsteroidColors[random.randi_range(0, AsteroidColors.size() - 1)]

	
	add_child(asteroid)
	Asteroids.append(asteroid)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	currentTime += delta
	if (currentTime > maxTime):
		currentTime = 0
		maxTime = random.randf_range(AsteroidDelay.x, AsteroidDelay.y)
		SpawnAsteroid()

