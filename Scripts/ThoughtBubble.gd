tool
extends Spatial

export(bool) var button setget _button
export(Array, NodePath) var linkedThoughts  

func _button(_value):
	print("button pressed")
	


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _input(_event):
	pass
