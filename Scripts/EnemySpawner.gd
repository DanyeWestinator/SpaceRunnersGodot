extends Node2D

var enemyPrefab = load("res://Scenes/EnemyShip.tscn")
onready var gm = get_node("..")
onready var player = get_node("../Player")
var rand = RandomNumberGenerator.new()

export (Vector2) var ShipDelay = Vector2(0.5, 1.5)
var ShipSpawnTime
var currentShipTime = 0

export (float) var laserBoltSpeed = 200
export (Color) var laserBoltColor = Color(0, 1, 0)
export (Vector2) var laserBoltScale = Vector2(4, 40)
export (float) var timeToShoot = .7
var ships = []

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	ShipSpawnTime = rand.randf_range(ShipDelay.x, ShipDelay.y)

func reset():
	var i = 0
	for ship in ships:
		ships.remove(i)
		i += 1
		#slightly complicated method to check if the ship is null
		if weakref(ship).get_ref():
			ship.clearShots()
			ship.queue_free()
	ships = []

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if gm.currentState != gm.States.Pause:
		currentShipTime += delta
		if currentShipTime >= ShipSpawnTime:
			SpawnShip()
			currentShipTime = 0
		
func SpawnShip():
	var ship = enemyPrefab.instance()
	var y = player.position.y - gm.screensize.y - 10
	var i = rand.randi_range(1, gm.columns.size())
	var x = gm.columns[i]
	ship.position = Vector2(x, y)
	ship.i = i
	ship.player = player
	ship.laserBoltSpeed = laserBoltSpeed
	ship.laserBoltColor = laserBoltColor
	ship.laserBoltScale = laserBoltScale
	ship.timeToShoot = timeToShoot
	
	add_child(ship)
	ships.append(ship)
	
