tool
extends Spatial

export(Array, String) var linkedThoughts  
export(Color) var bubbleColor
export(bool) var set_color setget _set_color
#export(bool) var load_links setget load_link_nodes
var MB_to_godot_path = "/run/media/cithoreal/Elements/MemoryBase/ToThoughts-Git/MB_to_godot.py"
var godot_to_nodes_path = "/run/media/cithoreal/Elements/MemoryBase/ToThoughts-Git/godot_to_nodes.py"
var link_scene = load("res://LineRenderer.tscn")
var mat = SpatialMaterial.new()

	
func _enter_tree():
	get_parent().get_parent().connect("save_thoughts" , self, "_on_save_thoughts")
	get_parent().get_parent().connect("load_links", self, "load_link_nodes")
	prepare_material()
	
func prepare_material():
	bubbleColor = get_child(1).material_override.albedo_color
	mat.flags_unshaded = true
	mat.flags_use_point_size = true
	mat.flags_transparent = true
	mat.flags_use_point_size = false
	mat.albedo_color = bubbleColor
	get_child(1).set_material_override(mat)

func _set_color(_value):
	mat.albedo_color = bubbleColor
	get_child(1).set_material_override(mat)
	
func initialize():
	get_child(0).text=get_name()
	load_thought_properties()
	#Lookup self in the memory base, exit if doesn't already exist
	#If it does exist, collect all properties/meta values and apply them to self

func load_thought_properties():
	print("Loading " + get_name())
	load_position()
	load_color()
	load_links()
	
func load_color():
	var output = []
	var timestamp = ""
	var r = ""
	var g = ""
	var b = ""
	var a = ""
	
	OS.execute(MB_to_godot_path, [get_name(), "|Color|", "|r|", "|Timestamp|"], true, output)
	output = process_mb_output(output)
	timestamp = output[len(output)-1]
	OS.execute(MB_to_godot_path, [get_name(), "|Color|", "|r|", timestamp], true, output)
	r = process_mb_output(output)[0]
	
	OS.execute(MB_to_godot_path, [get_name(), "|Color|", "|g|", "|Timestamp|"], true, output)
	output = process_mb_output(output)
	timestamp = output[len(output)-1]
	OS.execute(MB_to_godot_path, [get_name(), "|Color|", "|g|", timestamp], true, output)
	g = process_mb_output(output)[0]
	
	OS.execute(MB_to_godot_path, [get_name(), "|Color|", "|b|", "|Timestamp|"], true, output)
	output = process_mb_output(output)
	timestamp = output[len(output)-1]
	OS.execute(MB_to_godot_path, [get_name(), "|Color|", "|b|", timestamp], true, output)
	b = process_mb_output(output)[0]
	
	OS.execute(MB_to_godot_path, [get_name(), "|Color|", "|a|", "|Timestamp|"], true, output)
	output = process_mb_output(output)
	timestamp = output[len(output)-1]
	OS.execute(MB_to_godot_path, [get_name(), "|Color|", "|a|", timestamp], true, output)
	a = process_mb_output(output)[0]
	
	bubbleColor = Color(r,g,b,a)
	get_child(1).material_override.albedo_color = bubbleColor



func load_position():
	var output = []
	var timestamp = ""
	var x = ""
	var y = ""
	var z = ""
	OS.execute(MB_to_godot_path, [get_name(), "|Position|", "|x|", "|Timestamp|"], true, output)
	output = process_mb_output(output)
	timestamp = output[len(output)-1]
	OS.execute(MB_to_godot_path, [get_name(), "|Position|", "|x|", timestamp], true, output)
	x = process_mb_output(output)[0]
	
	OS.execute(MB_to_godot_path, [get_name(), "|Position|", "|y|", "|Timestamp|"], true, output)
	output = process_mb_output(output)
	timestamp = output[len(output)-1]
	OS.execute(MB_to_godot_path, [get_name(), "|Position|", "|y|", timestamp], true, output)
	y = process_mb_output(output)[0]
	
	OS.execute(MB_to_godot_path, [get_name(), "|Position|", "|z|", "|Timestamp|"], true, output)
	output = process_mb_output(output)
	timestamp = output[len(output)-1]
	OS.execute(MB_to_godot_path, [get_name(), "|Position|", "|z|", timestamp], true, output)
	z = process_mb_output(output)[0]
	
	transform.origin = Vector3(float(x),float(y),float(z))
	
	
func load_links():
	var output = []
	OS.execute(MB_to_godot_path, [get_name(), "|Link|"], true, output)
	for element in process_mb_output(output):
		linkedThoughts.append(element)
	#load_link_nodes()
	
func load_link_nodes():
	for link in linkedThoughts:
		var new_link_node = link_scene.instance()
		get_parent().get_parent().get_child(0).add_child(new_link_node)
		new_link_node.bubble1 = self
		new_link_node.set_owner(get_parent().get_parent())
		print(get_parent().get_node(link))
		new_link_node.bubble2 = get_parent().get_node(link)
		
	
func _on_save_thoughts(timestamp):
	save_name(timestamp)
	save_position(timestamp)
	save_basis(timestamp)
	save_links(timestamp)
	save_color(timestamp)
	
	#Collect all meta properties
	#execute external python script and pass it the node name and each property

func save_name(timestamp):
	# Name
	OS.execute(godot_to_nodes_path, [ "|Godot|", "|Thought|", "|Text|", get_name()], false)

func save_position(timestamp):
	# Position
	OS.execute(godot_to_nodes_path, [ "|Godot|", "|Bubble|", get_name(), "|Transform|", "|Position|", "|x|", timestamp, str(transform.origin.x)], false)
	OS.execute(godot_to_nodes_path, [ "|Godot|", "|Bubble|", get_name(), "|Transform|", "|Position|", "|y|", timestamp, str(transform.origin.y)], false)
	OS.execute(godot_to_nodes_path, [ "|Godot|", "|Bubble|", get_name(), "|Transform|", "|Position|", "|z|", timestamp, str(transform.origin.z)], false)

func save_basis(timestamp):
		# Basis
	OS.execute(godot_to_nodes_path, [ "|Godot|", "|Bubble|", get_name(), "|Transform|", "|Basis|", "|xx|", timestamp, str(transform.basis.x.x)], false)
	OS.execute(godot_to_nodes_path, [ "|Godot|", "|Bubble|", get_name(), "|Transform|", "|Basis|", "|xy|", timestamp, str(transform.basis.x.y)], false)
	OS.execute(godot_to_nodes_path, [ "|Godot|", "|Bubble|", get_name(), "|Transform|", "|Basis|", "|xz|", timestamp, str(transform.basis.x.z)], false)
	
	OS.execute(godot_to_nodes_path, [ "|Godot|", "|Bubble|", get_name(), "|Transform|", "|Basis|", "|yx|", timestamp, str(transform.basis.y.x)], false)
	OS.execute(godot_to_nodes_path, [ "|Godot|", "|Bubble|", get_name(), "|Transform|", "|Basis|", "|yy|", timestamp, str(transform.basis.y.y)], false)
	OS.execute(godot_to_nodes_path, [ "|Godot|", "|Bubble|", get_name(), "|Transform|", "|Basis|", "|yz|", timestamp, str(transform.basis.y.z)], false)
	
	OS.execute(godot_to_nodes_path, [ "|Godot|", "|Bubble|", get_name(), "|Transform|", "|Basis|", "|zx|", timestamp, str(transform.basis.z.x)], false)
	OS.execute(godot_to_nodes_path, [ "|Godot|", "|Bubble|", get_name(), "|Transform|", "|Basis|", "|zy|", timestamp, str(transform.basis.z.y)], false)
	OS.execute(godot_to_nodes_path, [ "|Godot|", "|Bubble|", get_name(), "|Transform|", "|Basis|", "|zz|", timestamp, str(transform.basis.z.z)], false)

func save_links(timestamp):
	for link in linkedThoughts:
		OS.execute(godot_to_nodes_path, [ "Godot", get_name(), "|Link|", str(link).replace("../", "")], false)

func save_color(timestamp):
	# Color
	OS.execute(godot_to_nodes_path, [ "|Godot|", "|Bubble|", get_name(), "|Material|", "|Color|", "|r|", timestamp, str(bubbleColor.r)], false)
	OS.execute(godot_to_nodes_path, [ "|Godot|", "|Bubble|", get_name(), "|Material|", "|Color|", "|g|", timestamp, str(bubbleColor.g)], false)
	OS.execute(godot_to_nodes_path, [ "|Godot|", "|Bubble|", get_name(), "|Material|", "|Color|", "|b|", timestamp, str(bubbleColor.b)], false)
	OS.execute(godot_to_nodes_path, [ "|Godot|", "|Bubble|", get_name(), "|Material|", "|Color|", "|a|", timestamp, str(bubbleColor.a)], false)

func process_mb_output(output):
	var text = output[0].replace("[(", "")
	var text_array = []
	text = text.replace(",)]", "")
	text = text.replace("\n", "")
	for i in text.split(",), ("):
		var element = i.replace("'","")
		if (element != "[]"):
			text_array.append(element)
	return text_array

