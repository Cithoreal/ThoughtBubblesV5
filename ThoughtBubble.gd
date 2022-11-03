tool
extends Spatial

export(bool) var button setget _button

func _button(value):
	print("button pressed")
	


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _input(event):
	print("test")
