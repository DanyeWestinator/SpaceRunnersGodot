extends Node

var random = RandomNumberGenerator.new()
onready var player = get_node("../Player")
##How far on either side of the screen to generate new stars
export (float) var buffer = 75
export (float) var StarSpeed
export (int) var InitialStarCount
export (Array, Texture) var StarList
export (Vector2) var StarScaleBounds
export (Vector2) var StarDelay
export (int) var MaxStarsPerCluster
var screensize
var currentTime = 0
var currentDelta = 0
var MaxDelta
var lastDistance = 0
var MaxTime
var CurrentStars = []
var gm

# Called when the node enters the scene tree for the first time.
func _ready():
	gm = get_node("..")
	screensize = gm.screensize
	buffer = (screensize.x / 2) - gm.columns[1]
	
	random.randomize()
	MaxTime = random.randf_range(StarDelay.x, StarDelay.y)
	MaxDelta = random.randf_range(StarDelay.x, StarDelay.y)
	currentTime = MaxTime
	for i in InitialStarCount:
		var x = random.randf_range(-1 * buffer, screensize.x + buffer)
		var y = random.randf_range((-1 * buffer), screensize.y)
		CreateStar(x, y)

		
		
		
func CreateStar(x, y):
	#creates the new star sprite
	var star = Sprite.new()
	
	#chooses the texture randomly
	star.texture = StarList[random.randi_range(0, StarList.size() - 1)]
	
	#scales the star randomly within the range
	var scale = random.randf_range(StarScaleBounds.x, StarScaleBounds.y)
	star.scale = Vector2(scale, scale)
	
	star.position = Vector2(x, y)
	add_child(star)
	CurrentStars.append(star)
	

func reset():
	
	#destroy all stars
	for i in range(CurrentStars.size()):
		var star = CurrentStars[i]
		#print(star)
		CurrentStars[i] = null
		star.queue_free()
	CurrentStars = []
	self._ready()
	currentDelta = 0
	lastDistance = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#add delta to currentTime
	currentTime += delta
	var playerPos = player.position
	currentDelta += player.distanceTravelled - lastDistance
	
	#Check if it's time to spawn a new star cluster
	#if (currentTime >= MaxTime):
	if (currentDelta >= MaxDelta):
		currentTime = 0
		currentDelta = 0
		MaxTime = random.randf_range(StarDelay.x, StarDelay.y)
		MaxDelta = random.randf_range(StarDelay.x, StarDelay.y)
		var numStars = random.randi_range(1, MaxStarsPerCluster)
		
		#Create n stars
		for i in numStars:
			var x = random.randf_range(-1 * buffer, screensize.x + buffer)
			var y =  playerPos.y - screensize.y
			CreateStar(x, y)
	for star in CurrentStars:
		#star.position.y += (StarSpeed * delta)
		if (star.position.y >= playerPos.y + buffer):
			CurrentStars.erase(star)
			star.queue_free()
	lastDistance = player.distanceTravelled

