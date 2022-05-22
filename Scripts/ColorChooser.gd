extends Node2D

export (float) var spacing = 125
export (Array, Color) var PlayerColors
var player
var base


# Called when the node enters the scene tree for the first time.
func _ready():
	base = load("res://Scenes/BaseColorButton.tscn")
	#gets the player :(
	player = get_tree().root.get_child(0).get_child(0)
	#base.visible = false
	var x = -1 * spacing
	var y = $StartCenter.position.y
	for color in PlayerColors:
		if x > spacing:
			x = -1 * spacing
			y += spacing
		var new = base.instance()
		add_child(new)
		new.connect("pressed", player, "_on_color_pressed", [color])
		new.position = Vector2(x, y)
		x += spacing
		new.modulate = color
		

		

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
