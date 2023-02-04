tool
extends Spatial

export(String) var space_context
export(Array, String) var parent_thoughts
export(Array, String) var child_thoughts  
export var bubble_color = Color(0.329412, 0.517647, 0.6, 0.533333)

var MB_to_godot_path = "/run/media/cithoreal/Elements/MemoryBase/ToThoughts-Git/MB_to_godot.py"
var godot_to_nodes_path = "/run/media/cithoreal/Elements/MemoryBase/ToThoughts-Git/godot_to_nodes.py"
var link_scene = load("res://LineRenderer.tscn")
var mat = SpatialMaterial.new()


# ----------------------- INITILIZATION ----------------------- #
func _enter_tree():
	if (get_parent().get_parent().get_name() != get_viewport().get_child(0).get_name()):
		get_parent().get_parent().connect("save_thoughts" , self, "save_thought")
		get_parent().get_parent().connect("load_parents", self, "load_parents")
		get_parent().get_parent().connect("load_links", self, "load_link_nodes")
	prepare_material()
	
	
	
func prepare_material():
	bubble_color = get_child(0).material.albedo_color
	mat.flags_unshaded = true
	mat.flags_use_point_size = true
	mat.flags_transparent = true
	mat.flags_use_point_size = false
	mat.albedo_color = bubble_color
	get_child(0).set_material_override(mat)

func set_color(color):
	bubble_color = color
	get_child(0).material_override.albedo_color = bubble_color
	
func initialize():
	get_parent().get_child(0).set_thought(get_parent().get_name())
	parent_thoughts.append(get_parent().get_parent().get_parent().get_name())
	space_context = get_parent().get_parent().get_parent().get_name()
	#Lookup self in the memory base, exit if doesn't already exist
	#If it does exist, collect all properties/meta values and apply them to self
	
# ----------------------- Loading ----------------------- #
func load_thought_properties(timestamp):
	print(str(Time.get_time_string_from_system()) + ": Loading " + get_parent().get_name())
	load_position(timestamp)
	print(str(Time.get_time_string_from_system()) + ": " + get_parent().get_name() + " After Position")
	load_color(timestamp)
	print(str(Time.get_time_string_from_system()) + ": " + get_parent().get_name() + " After Color")
	load_links(timestamp)
	print(str(Time.get_time_string_from_system()) + ": " + get_parent().get_name() + " After Links")



func load_position(timestamp):
	var x = ""
	var y = ""
	var z = ""
	print(get_parent().get_name() + " loading position")
	x = get_bubble_property("Position" ,"x", timestamp)
	y = get_bubble_property("Position", "y", timestamp)
	z = get_bubble_property("Position", "z", timestamp)
	#print(get_parent().get_name() + ": " + str(Vector3(float(x),float(y),float(z))))
	if (x == null):
		x = 0
	if (y == null):
		y = 0
	if (z == null):
		z = 0
	if (x == null || y == null || z == null):
		pass
		# Set to cursor position
	else:
		get_parent().transform.origin = Vector3(float(x),float(y),float(z))
	
func load_color(timestamp):
	var r = ""
	var g = ""
	var b = ""
	var a = ""
	
	r = get_bubble_property("Color", "r", timestamp)
	g = get_bubble_property("Color", "g", timestamp)
	b = get_bubble_property("Color", "b", timestamp)
	a = get_bubble_property("Color", "a", timestamp)
	
	if (r == null || g == null || b == null || a == null):
		bubble_color = Color(0.329412, 0.517647, 0.6, 0.533333)
	else:
		bubble_color = Color(r,g,b,a)
	get_child(0).material_override.albedo_color = bubble_color

func load_links(timestamp):
	var output = []
	OS.execute(MB_to_godot_path, [get_parent().get_parent().get_parent().get_name(), get_parent().get_name(), "|Link|", timestamp], true, output)
	for element in process_mb_output(output):
		child_thoughts.append(element)

func load_parents():
	for link in child_thoughts:
		load_parent_links(link)

func load_parent_links(link_to):
	if (get_parent().get_parent().get_node(link_to).get_child(1).parent_thoughts.find(get_parent().get_name()) == -1):
		get_parent().get_parent().get_node(link_to).get_child(1).parent_thoughts.append(get_parent().get_name())

func get_latest_bubble_property_value(property, element):
	var output = []
	var timestamp = ""
	#Add further thought context ability to this property value command
	#print(get_parent().get_name())
	OS.execute(MB_to_godot_path, [get_parent().get_parent().get_parent().get_name(), get_parent().get_name(), "|" + property + "|", "|" + element + "|", "|Timestamp|"], true, output)
	output = process_mb_output(output)
	if (str(output) != "[]"):
		timestamp = output[len(output)-1]
		OS.execute(MB_to_godot_path, [get_parent().get_parent().get_parent().get_name(), get_parent().get_name(), "|" + property + "|", "|" + element + "|", timestamp], true, output)
		if (len(process_mb_output(output)) > 0):
			return process_mb_output(output)[len(process_mb_output(output))-1]
		else:
			return null
	else:
		return null

func get_bubble_property(property,element,timestamp):
	var output = []
	OS.execute(MB_to_godot_path, [get_parent().get_parent().get_parent().get_name(), get_parent().get_name(), "|" + property + "|", "|" + element + "|", "|Timestamp|"], true, output)
	output = process_mb_output(output)
	for time in output:
			if (time < timestamp):
				timestamp = time
				
	if (output.find(timestamp) > -1):
		OS.execute(MB_to_godot_path, [get_parent().get_parent().get_parent().get_name(), get_parent().get_name(), "|" + property + "|", "|" + element + "|", timestamp], true, output)
		if (len(process_mb_output(output)) > 0):
			return process_mb_output(output)[len(process_mb_output(output))-1]
		else:
			return null
	else:
		get_parent().visible = false
# ----------------------- Saving ----------------------- #
	
func save_thought(timestamp):
	save_name(timestamp)
	save_position(timestamp)
	save_basis(timestamp)
	save_links(timestamp)
	save_color(timestamp)
	
	#Collect all meta properties
	#execute external python script and pass it the node name and each property

func save_name(timestamp):
	# Name
	OS.execute(godot_to_nodes_path, [ "|Godot|", "|Thought|", "|Text|", get_parent().get_name()], false)

func save_position(timestamp):
	# Position
	save_bubble_property("Transform", "Position", "x", timestamp, str(get_parent().transform.origin.x))
	save_bubble_property("Transform", "Position", "y", timestamp, str(get_parent().transform.origin.y))
	save_bubble_property("Transform", "Position", "z", timestamp, str(get_parent().transform.origin.z))

func save_basis(timestamp):
		# Basis
	save_bubble_property("Transform", "Basis", "xx", timestamp, str(get_parent().transform.basis.x.x))
	save_bubble_property("Transform", "Basis", "xy", timestamp, str(get_parent().transform.basis.x.y))
	save_bubble_property("Transform", "Basis", "xz", timestamp, str(get_parent().transform.basis.x.z))
	
	save_bubble_property("Transform", "Basis", "yx", timestamp, str(get_parent().transform.basis.y.x))
	save_bubble_property("Transform", "Basis", "yy", timestamp, str(get_parent().transform.basis.y.y))
	save_bubble_property("Transform", "Basis", "yz", timestamp, str(get_parent().transform.basis.y.z))
	
	save_bubble_property("Transform", "Basis", "zx", timestamp, str(get_parent().transform.basis.z.x))
	save_bubble_property("Transform", "Basis", "zy", timestamp, str(get_parent().transform.basis.z.y))
	save_bubble_property("Transform", "Basis", "zz", timestamp, str(get_parent().transform.basis.z.z))

func save_color(timestamp):
	# Color
	save_bubble_property("Material", "Color", "r", timestamp, str(bubble_color.r))
	save_bubble_property("Material", "Color", "g", timestamp, str(bubble_color.g))
	save_bubble_property("Material", "Color", "b", timestamp, str(bubble_color.b))
	save_bubble_property("Material", "Color", "a", timestamp, str(bubble_color.a))

func save_bubble_property(field, property, element, timestamp, value):
	if (get_latest_bubble_property_value(property, element) != value && value != ""):
		var save_array = ["|Godot|", "|Bubble|", get_parent().get_parent().get_parent().get_name() , get_parent().get_name(), "|" + field + "|", "|" + property + "|", "|" + element + "|", timestamp, value]
		#print(lookup_array)
		OS.execute(godot_to_nodes_path, save_array, false)

func save_links(timestamp):
	for link in child_thoughts:
		print(get_parent().get_name() + " saving... " + link)
		OS.execute(godot_to_nodes_path, [ "|Godot|", get_parent().get_parent().get_parent().get_name(), get_parent().get_name(), get_parent().get_name(), "|Link|", timestamp, str(link).replace("../", "")], false)

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
	
# ----------------------- Linking ----------------------- #

func new_linked_thought(new_thought):
	if (child_thoughts.find(new_thought) == -1):
		if (get_parent().get_parent().find_node(new_thought) == null):
			var thoughts = []
			for thought in parent_thoughts:
				thoughts.append(thought)
			thoughts.append(get_parent().get_name())
			print("Creating and linking " + new_thought)
			get_parent().get_parent().create_and_link_new_thought(new_thought, thoughts, global_transform.origin)
		else:
			child_thoughts.append(new_thought)
			load_parent_links(new_thought)
			get_parent().get_parent().get_node(new_thought).get_child(1).load_link_nodes()
		print("Link to " + str(get_parent().get_parent().get_node(new_thought)))

#Runs on signal from thought space after all thoughts have been loaded into the scene
func load_link_nodes():
	#clear existing link renderers
	for link in get_parent().get_child(3).get_children():
		link.free()
	#print("Loading Links")
	var linked_nodes = process_links()
	if (len(linked_nodes)>0):
		for node in process_links():
			var new_link_node = link_scene.instance()
			get_parent().get_child(3).add_child(new_link_node)
			#print(str(self) + " " + str(len(parent_thoughts)-1))
			new_link_node.bubble1 = node
			new_link_node.bubble2 = get_parent()
			new_link_node.set_owner(get_viewport().get_child(0))
			new_link_node.initialize()

func process_links():
	if (len(parent_thoughts) <= 1):
		#Just render link to the thought space owner
		return [get_parent().get_parent().get_parent()]
	
	var ordered_thoughts = []
	# Don't know how to initiate lists of specified sizes in gdscript
	# and too lazy to look it up when I can just do this
	for i in range(1, len(parent_thoughts)):
		ordered_thoughts.append([])
	
	#How many of my parent thoughts does each thought share as child thoughts?
	#If a parent thought's child thoughts include 0 of my own parent thoughts
	#That means it is a direct parent of mine, and I wish to render a line to it
	for i in range(1, len(parent_thoughts)):
		var shared_count = 0
		var parent_thought_1 = get_parent().get_parent().get_node(parent_thoughts[i])
		for n in range(1, len(parent_thoughts)):
			
				var parent_thought_2 = get_parent().get_parent().get_node(parent_thoughts[n])
				if (parent_thought_1.get_name() != parent_thought_2.get_name() && parent_thought_1.get_child(1).child_thoughts.find(parent_thought_2.get_name()) != -1):
					shared_count += 1

					
		ordered_thoughts[shared_count].append(parent_thought_1.get_name())
	
	var output_thoughts = []
	for parent in ordered_thoughts[0]:
		output_thoughts.append(get_parent().get_parent().get_node(parent))
	return output_thoughts

func clear_links():
	for link in get_parent().get_child(3).get_children():
		link.free()

# ----------------------- Focus ----------------------- #

func focus():
	for child in child_thoughts:
		get_parent().get_child(2).new_thought_in_space(child)
		get_parent().get_parent().get_node(child).check_context()
		get_parent().get_child(2).get_node(child).translate(get_parent().get_parent().get_node(child).transform.origin - get_parent().transform.origin - Vector3(0,-2,0))
		
	#Create new instance of each child
	#Check child link structure to see if it exists in other focused contexts

func unfocus():
	for child in child_thoughts:
		#print("Find them all as siblings and enable all of them")
		get_parent().get_parent().get_node(child).visible = true
		for link in get_parent().get_parent().get_node(child).get_child(3).get_children():
			link.visible = true	
	get_parent().get_child(2).clear_scene()

func check_context():
	#subtracting one because the thought space context is not considered
	var num_parents = len(parent_thoughts) - 1
	for i in range(1, len(parent_thoughts)):
		#print (parent_thoughts[i] + " is focused: " + get_parent().get_parent().get_node(parent_thoughts[i]).is_focused)
		if (get_parent().get_parent().get_node(parent_thoughts[i]).is_focused):
			num_parents -= 1
			
	if (num_parents <= 0):
		get_parent().visible = false
		for link in get_parent().get_child(3).get_children():
			link.visible = false	
	
