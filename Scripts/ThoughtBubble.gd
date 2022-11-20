tool
extends Spatial

export(bool) var button setget _button
export(Array, String) var linkedThoughts  
var MB_to_godot_path = "/run/media/cithoreal/Elements/MemoryBase/ToThoughts-Git/MB_to_godot.py"
var godot_to_nodes_path = "/run/media/cithoreal/Elements/MemoryBase/ToThoughts-Git/godot_to_nodes.py"
onready var thoughtspace_node = get_parent().get_parent()

func _button(_value):
	print("button pressed")
	
func _ready():
	
	get_child(0).text=get_name()
	thoughtspace_node.connect("save_thoughts" , self, "_on_save_thoughts")
	#load_thoughts()
	#Lookup self in the memory base, exit if doesn't already exist
	#If it does exist, collect all properties/meta values and apply them to self
	
func load_thoughts():
	print("Loading " + get_name())
	load_position()
	load_links()

func load_position():
	var output = []
	var x = ""
	var y = ""
	var z = ""
	OS.execute(MB_to_godot_path, [get_name(), "|Position|", "|x|"], true, output)
	x = output[0].replace("[('", "")
	x = x.replace("',)]", "")
	OS.execute(MB_to_godot_path, [get_name(), "|Position|", "|y|"], true, output)
	y = output[0].replace("[('", "")
	y = y.replace("',)]", "")
	OS.execute(MB_to_godot_path, [get_name(), "|Position|", "|z|"], true, output)
	z = output[0].replace("[('", "")
	z = z.replace("',)]", "")
	transform.origin = Vector3(float(x),float(y),float(z))
	
	
func load_links():
	var output = []
	OS.execute(MB_to_godot_path, [get_name(), "|Link|"], true, output)
	var text = output[0].replace("[(", "")
	text = text.replace(",)]", "")
	text = text.replace("\n", "")
	for i in text.split(",), ("):
		var linked_node = i.replace("'","")
		if (linked_node != "[]"):
			linkedThoughts.append(linked_node)
	
func _on_save_thoughts():
	# Name
	OS.execute(godot_to_nodes_path, ["|Godot|", "|Thought|", "|Text|", get_name()], false)
	# Position
	OS.execute(godot_to_nodes_path, ["|Godot|", "|Bubble|", get_name(), "|Transform|", "|Position|", "|x|", str(transform.origin.x)], false)
	OS.execute(godot_to_nodes_path, ["|Godot|", "|Bubble|", get_name(), "|Transform|", "|Position|", "|y|", str(transform.origin.y)], false)
	OS.execute(godot_to_nodes_path, ["|Godot|", "|Bubble|", get_name(), "|Transform|", "|Position|", "|z|", str(transform.origin.z)], false)
	# Basis
	OS.execute(godot_to_nodes_path, ["|Godot|", "|Bubble|", get_name(), "|Transform|", "|Basis|", "|xx|", str(transform.basis.x.x)], false)
	OS.execute(godot_to_nodes_path, ["|Godot|", "|Bubble|", get_name(), "|Transform|", "|Basis|", "|xy|", str(transform.basis.x.y)], false)
	OS.execute(godot_to_nodes_path, ["|Godot|", "|Bubble|", get_name(), "|Transform|", "|Basis|", "|xz|", str(transform.basis.x.z)], false)
	
	OS.execute(godot_to_nodes_path, ["|Godot|", "|Bubble|", get_name(), "|Transform|", "|Basis|", "|yx|", str(transform.basis.y.x)], false)
	OS.execute(godot_to_nodes_path, ["|Godot|", "|Bubble|", get_name(), "|Transform|", "|Basis|", "|yy|", str(transform.basis.y.y)], false)
	OS.execute(godot_to_nodes_path, ["|Godot|", "|Bubble|", get_name(), "|Transform|", "|Basis|", "|yz|", str(transform.basis.y.z)], false)
	
	OS.execute(godot_to_nodes_path, ["|Godot|", "|Bubble|", get_name(), "|Transform|", "|Basis|", "|zx|", str(transform.basis.z.x)], false)
	OS.execute(godot_to_nodes_path, ["|Godot|", "|Bubble|", get_name(), "|Transform|", "|Basis|", "|zy|", str(transform.basis.z.y)], false)
	OS.execute(godot_to_nodes_path, ["|Godot|", "|Bubble|", get_name(), "|Transform|", "|Basis|", "|zz|", str(transform.basis.z.z)], false)
	
	for link in linkedThoughts:
		OS.execute(godot_to_nodes_path, ["Godot", get_name(), "|Link|", str(link).replace("../", "")], false)
	#Collect all meta properties
	#execute external python script and pass it the node name and each property
