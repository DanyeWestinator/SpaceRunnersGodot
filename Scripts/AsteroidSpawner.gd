extends Node

var AsteroidPrefab = load("res://Scenes/AsteroidPrefab.tscn")
export (Array, Texture) var AsteroidTextures
export (Array, Color) var AsteroidColors
export (Vector2) var AsteroidDelay = Vector2(0.5, 2)
export (float) var AsteroidSpeed = 5
export (float) var AsteroidRotateSpeed = 25
export (Vector2) var AsteroidScale = Vector2(1, 4)
onready var columns = get_node("..").columns
onready var screensize = get_node("..").screensize
var printed = false
var Asteroids = []
var random = RandomNumberGenerator.new()
export (bool) var SpawnAsteroids = true

onready var gm = get_tree().root.get_child(0)


var currentTime = 0
var maxTime
var lastPos
var player

func reset():
	for i in range(Asteroids.size()):
		var asteroid = Asteroids[i]
		Asteroids[i] = null
		asteroid.queue_free()
	Asteroids = []


func _ready():
	maxTime = random.randf_range(AsteroidDelay.x, AsteroidDelay.y)
	screensize = null
	player = $"../Player"
	lastPos = player.position
	

func SpawnAsteroid():
	#initializes the asteroid
	var asteroid = AsteroidPrefab.instance()
	#error check for screensize existing
	if (screensize == null):
		screensize = get_node("..").screensize
	#Sets asteroid transform
	var playerPos = get_node("../Player").position
	asteroid.y_bound = playerPos.y + 10
	
	var scale = random.randf_range(AsteroidScale.x, AsteroidScale.y)
	asteroid.scale = Vector2(scale, scale)
	asteroid.position.y = playerPos.y - screensize.y - 10
	var x = random.randi_range(1, columns.size())
	x = columns[x]
	asteroid.position.x = x
	
	#sets asteroid variables
	asteroid.MoveSpeed = random.randf_range(AsteroidSpeed * - 0.5, AsteroidSpeed)
	asteroid.RotateSpeed = random.randf_range(-1 * AsteroidRotateSpeed, AsteroidRotateSpeed)
	asteroid.get_node("Sprite").modulate = AsteroidColors[random.randi_range(0, AsteroidColors.size() - 1)]

	
	add_child(asteroid)
	Asteroids.append(asteroid)

func Serialize():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if gm.currentState == gm.States.Play:
	currentTime += delta
	if (currentTime > maxTime and SpawnAsteroids == true and gm.currentState != gm.States.Pause):
		currentTime = 0
		maxTime = random.randf_range(AsteroidDelay.x, AsteroidDelay.y)
		SpawnAsteroid()

	lastPos = player.position
