extends Node2D

var screensize
var columns = { 1 : 0.16666, 2 : 0.33333, 3 : 0.5, 4 : 0.66666, 5 : 0.833333,}
export (Texture) var starTexture
export (bool) var DisplayColumns = false
var loaded = false


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



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	return

