tool
extends Spatial

export(bool) var button setget _button
export(Array, NodePath) var linkedThoughts  
var thoughtbubbles_path = "Thought_Space/----Thought Bubbles----"
var thoughtspace_path = "Thought_Space"
onready var thoughtspace = get_node("/root/EditorNode/@@596/@@597/@@605/@@607/@@611/@@615/@@616/@@617/@@633/@@634/@@643/@@644/@@6618/@@6450/@@6451/@@6452/@@6453/@@6454/@@6455/root/Thought_Space")

func _button(_value):
	print("button pressed")
	
func _ready():
	get_child(0).text=get_name()
	thoughtspace.connect("save_thoughts" , self, "_on_save_thoughts")
	#Lookup self in the memory base, exit if doesn't already exist
	#If it does exist, collect all properties/meta values and apply them to self

func _on_save_thoughts():
	print(get_name() + " is saving")
	#Collect all meta properties
	#execute external python script and pass it the node name and each property
