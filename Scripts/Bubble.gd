@tool
extends Node3D

@export var space_context: String
@export var  parent_thoughts : Array[String]
@export var child_thoughts :Array[String]
@export var bubble_color: Color = Color(0.329412, 0.517647, 0.6, 0.533333)

var link_scene = load("res://Scenes/LineRenderer.tscn")
var mat = StandardMaterial3D.new()

var bubble_interface_node 
var parent_space_node
var parent_bubble_node
var thoughtbubble_store

# ----------------------- INITIALIZATION ----------------------- #
#region Initialization
func _enter_tree():
	
	bubble_interface_node = get_parent()
	parent_space_node = get_parent().get_parent()
	parent_bubble_node = get_parent().get_parent().get_parent()
	thoughtbubble_store = get_viewport().get_child(0).get_node("ThoughtBubbleStore")
	#Check if parent node is "Space" and not "Scene" to ensure this bubble is not top level
	if (parent_space_node.get_name() != get_viewport().get_child(0).get_name()):
		#print_debug("signals connected")
		#parent_space_node.connect("save_thoughts",Callable(self,"_save_thought"))
		parent_space_node.connect("save_thoughts",Callable(self,"save_thought"))
		parent_space_node.connect("load_parents",Callable(self,"_load_parents"))
		parent_space_node.connect("load_links",Callable(self,"_load_link_nodes"))
		bubble_color = get_child(0).material.albedo_color
	prepare_material()

	
func prepare_material():
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
	bubble_interface_node.get_child(0).set_thought(bubble_interface_node.get_name())
	parent_thoughts.append(parent_bubble_node.get_name())
	space_context = parent_bubble_node.get_name()
	#Lookup self in the memory base, exit if doesn't already exist
	#If it does exist, collect all properties/meta values and apply them to self
	
func get_child_thoughts():
	return child_thoughts
	
func set_shape(shape):
	get_child(0).free()
	var new_shape 
	match(shape):
		0:
			#print_debug("Sphere")
			new_shape = CSGSphere3D.new()
			new_shape.radius = .623
			new_shape.radial_segments = 16
			new_shape.rings = 16
			get_child(0).get_child(0).shape = SphereShape3D
			#get_parent().shape = 0
		1:
			#print_debug("Cube")
			new_shape = CSGBox3D.new()
			get_child(0).get_child(0).shape = BoxShape3D
			#get_parent().shape = 1
		2:
			#print_debug("Cylinder")
			new_shape= CSGCylinder3D.new()
			new_shape.height = 1
			new_shape.sides = 16
			get_child(0).get_child(0).shape = CylinderShape3D
			#get_parent().shape = 2
	add_child(new_shape)
	move_child(new_shape,0)
	new_shape.set_owner(get_viewport().get_child(0))
	prepare_material()
	#endregion

func position_updated():
	print_debug("Position Updated " + bubble_interface_node.get_name() + " " + str(bubble_interface_node.transform.origin))
	save_position(str(Time.get_unix_time_from_system()))
# ----------------------- Loading ----------------------- #
#region Loading


func load_thought_properties(timestamp: float):
	print_debug(str(Time.get_time_string_from_system()) + ": Loading " + bubble_interface_node.get_name())
	if timestamp == 0:
		timestamp = thoughtbubble_store.get_latest_timestamp(bubble_interface_node.get_name())
	print_debug(timestamp)
	

	var x_position =  thoughtbubble_store.load_position_x(bubble_interface_node.get_name(), timestamp)
	var y_position =  thoughtbubble_store.load_position_y(bubble_interface_node.get_name(), timestamp)
	var z_position =  thoughtbubble_store.load_position_z(bubble_interface_node.get_name(), timestamp)
	print_debug("b 104 - type of x: ", typeof(x_position))
	print_debug("Loaded Position x: " + str(x_position))
	if typeof(x_position) != 0:
		bubble_interface_node.position.x = float(x_position)
	if typeof(x_position) != 0:
		bubble_interface_node.position.y = float(y_position)
	if typeof(x_position) != 0:
		bubble_interface_node.position.z = float(z_position)

	return

	#print_debug(str(Time.get_time_string_from_system()) + ": " + bubble_interface_node.get_name() + " After Position")
	
	bubble_color = thoughtbubble_store.load_color(bubble_interface_node.get_name(), timestamp)
	#print_debug(str(Time.get_time_string_from_system()) + ": " + bubble_interface_node.get_name() + " After Color")
	get_child(0).material_override.albedo_color = bubble_color
	bubble_interface_node.bubble_color = bubble_color

	var shape_id = thoughtbubble_store.load_shape(bubble_interface_node.get_name(), timestamp)
	get_parent().shape = shape_id

	var links = thoughtbubble_store.load_links(bubble_interface_node.get_name(), timestamp)
	#print_debug(str(Time.get_time_string_from_system()) + ": " + bubble_interface_node.get_name() + " After Links")
	

func load_links(timestamp):
	#Find and use proper timestamp
	#	var get_array = thoughtbubble_store.get_from_orbitdb([parent_bubble_node.get_name(),bubble_interface_node.get_name(), "`Link`"])
	var links = thoughtbubble_store.get_bubble_property([parent_bubble_node.get_name(), bubble_interface_node.get_name(), "`Link`"], timestamp)
	print_debug(links)
	for link in links:
		if (link != ""):
			child_thoughts.append(link)
	#	var timestamps = thoughtbubble_store.get_from_orbitdb(["`Timestamp`"])
	#	if (get_array[0] != ""):
	#		#print_debug(get_parent().get_name(), " ", get_array)
	#		#OS.execute(MB_to_godot_path, [parent_bubble_node.get_name(), bubble_interface_node.get_name(), "`Link`", timestamp], true, output)
	#		for element in get_array:
	#			if !timestamps.has(element):
	#				child_thoughts.append(element)

func _load_parents():
	for link in child_thoughts:
		load_parent_links(link)

func load_parent_links(link_to):
	if (parent_space_node.get_node(link_to).get_child(1).parent_thoughts.find(bubble_interface_node.get_name()) == -1):
		parent_space_node.get_node(link_to).get_child(1).parent_thoughts.append(bubble_interface_node.get_name())

#endregion
# ----------------------- Saving ----------------------- #
#region Saving
	
func save_thought(timestamp):
	print_debug("Saving " + bubble_interface_node.get_name() + " at " + str(timestamp))
	timestamp = str(timestamp)
	#Check each value to see if it has changed before saving
	save_timestamp(timestamp)
	save_name(timestamp)

	save_position(timestamp)
	return
	save_rotation(timestamp)
	save_scale(timestamp)
	save_color(timestamp)
	save_shape(timestamp)
	save_links(timestamp)
	#Collect all meta properties
	#execute external python script and pass it the node name and each property

func save_timestamp(timestamp):
	var save_array = [
		["Timestamps", "Timestamps"],
		["Timestamp-[%s]" % timestamp, timestamp]
		]
	thoughtbubble_store.save(timestamp, save_array)


func save_name(timestamp):
	var save_array = [
		["Text-Thought", "Text-Thought"],
		[parent_bubble_node.get_name(), parent_bubble_node.get_name()], #needs the whole thoughtspace context chain
		[bubble_interface_node.get_name(), bubble_interface_node.get_name()]
	]
	print_debug(save_array)
	thoughtbubble_store.save(timestamp, save_array)

	# Note: saves whole chain for context, probably inefficient
	# Want to update latest change timestamps for thoughtspace, should be able to just tell the thought space to update that

func save_position(timestamp):
	# Position
	save_position_x(timestamp);
	save_position_y(timestamp);
	save_position_z(timestamp);

func save_position_x(timestamp):
	var save_array = [
		["Timestamp-[%s]" % timestamp, timestamp],
		["Position-[X,Y,Z]", "x, y, z"], 
		["x-pos", "x-pos"],
		[str(bubble_interface_node.transform.origin.x), str(bubble_interface_node.transform.origin.x)],
		
		[parent_bubble_node.get_name(), parent_bubble_node.get_name()], #needs the whole thoughtspace context chain
		[bubble_interface_node.get_name(), bubble_interface_node.get_name()]
	]
	print_debug(save_array)
	thoughtbubble_store.save(timestamp, save_array)
func save_position_y(timestamp):
	var save_array = [
		["Timestamp-[%s]" % timestamp, timestamp],
		["Position-[X,Y,Z]", "x, y, z"], 
		["y-pos", "y-pos"],
		[str(bubble_interface_node.transform.origin.y), str(bubble_interface_node.transform.origin.y)],
		[parent_bubble_node.get_name(), parent_bubble_node.get_name()], #needs the whole thoughtspace context chain
		[bubble_interface_node.get_name(), bubble_interface_node.get_name()]
	]
	print_debug(save_array)
	thoughtbubble_store.save(timestamp, save_array)
func save_position_z(timestamp):
	var save_array = [
		["Timestamp-[%s]" % timestamp, timestamp],
		["Position-[X,Y,Z]", "x, y, z"], 
		["z-pos","z-pos"],
		[str(bubble_interface_node.transform.origin.z), str(bubble_interface_node.transform.origin.z)],
		[parent_bubble_node.get_name(), parent_bubble_node.get_name()], #needs the whole thoughtspace context chain
		[bubble_interface_node.get_name(), bubble_interface_node.get_name()]
	]
	print_debug(save_array)
	thoughtbubble_store.save(timestamp, save_array)

func save_rotation(timestamp):

	save_rotation_x(timestamp)
	save_rotation_y(timestamp)
	save_rotation_z(timestamp)


func save_rotation_x(timestamp):
	var save_array = [
		["Timestamp-[%s]" % timestamp, timestamp],
		["Rotation", "x, y, z"], 
		["x-rotation","x-rotation"],
		[str(bubble_interface_node.transform.basis.x.x), str(bubble_interface_node.transform.basis.x.x)],
		[parent_bubble_node.get_name(), parent_bubble_node.get_name()], 
		[bubble_interface_node.get_name(), bubble_interface_node.get_name()]
	]
	print_debug(save_array)
	thoughtbubble_store.save(timestamp, save_array)

func save_rotation_y(timestamp):
	var save_array = [
		["Timestamp-[%s]" % timestamp, timestamp],
		["Rotation", "x, y, z"], 
		["y-rotation","y-rotation"],
		[str(bubble_interface_node.transform.basis.y.y), str(bubble_interface_node.transform.basis.y.y)],
		[parent_bubble_node.get_name(), parent_bubble_node.get_name()], 
		[bubble_interface_node.get_name(), bubble_interface_node.get_name()]
	]
	print_debug(save_array)
	thoughtbubble_store.save(timestamp, save_array)

func save_rotation_z(timestamp):
	var save_array = [
		["Timestamp-[%s]" % timestamp, timestamp],
		["Rotation", "x, y, z"], 
		["z-rotation","z-rotation"],
		[str(bubble_interface_node.transform.basis.z.z), str(bubble_interface_node.transform.basis.z.z)],
		[parent_bubble_node.get_name(), parent_bubble_node.get_name()], 
		[bubble_interface_node.get_name(), bubble_interface_node.get_name()]
	]
	print_debug(save_array)
	thoughtbubble_store.save(timestamp, save_array)

func save_scale(timestamp):
	save_scale_x(timestamp)
	save_scale_y(timestamp)
	save_scale_z(timestamp)

func save_scale_x(timestamp):
	var save_array = [
		["Timestamp-[%s]" % timestamp, timestamp],
		["Scale", "x, y, z"], 
		["x-scale","x-scale"],
		[str(bubble_interface_node.transform.scale.x), str(bubble_interface_node.transform.scale.x)],
		[parent_bubble_node.get_name(), parent_bubble_node.get_name()], 
		[bubble_interface_node.get_name(), bubble_interface_node.get_name()]
	]
	print_debug(save_array)
	thoughtbubble_store.save(timestamp, save_array)

func save_scale_y(timestamp):
	var save_array = [
		["Timestamp-[%s]" % timestamp, timestamp],
		["Scale", "x, y, z"], 
		["y-scale","y-scale"],
		[str(bubble_interface_node.transform.scale.y), str(bubble_interface_node.transform.scale.y)],
		[parent_bubble_node.get_name(), parent_bubble_node.get_name()], 
		[bubble_interface_node.get_name(), bubble_interface_node.get_name()]
	]
	print_debug(save_array)
	thoughtbubble_store.save(timestamp, save_array)

func save_scale_z(timestamp):
	var save_array = [
		["Timestamp-[%s]" % timestamp, timestamp],
		["Scale", "x, y, z"], 
		["z-scale","z-scale"],
		[str(bubble_interface_node.transform.scale.z), str(bubble_interface_node.transform.scale.z)],
		[parent_bubble_node.get_name(), parent_bubble_node.get_name()], 
		[bubble_interface_node.get_name(), bubble_interface_node.get_name()]
	]
	print_debug(save_array)
	thoughtbubble_store.save(timestamp, save_array)

func save_color(timestamp):
	save_color_r(timestamp)
	save_color_g(timestamp)
	save_color_b(timestamp)
	save_color_a(timestamp)

func save_color_r(timestamp):
	var save_array = [
		["Timestamp-[%s]" % timestamp, timestamp],
		["Color", "Color"], 
		["r-color","r-color"],
		[str(bubble_color.r), str(bubble_color.r)],
		[parent_bubble_node.get_name(), parent_bubble_node.get_name()], 
		[bubble_interface_node.get_name(), bubble_interface_node.get_name()]
	]
	print_debug(save_array)
	thoughtbubble_store.save(timestamp, save_array)

func save_color_g(timestamp):
	var save_array = [
		["Timestamp-[%s]" % timestamp, timestamp],
		["Color", "Color"], 
		["g-color","g-color"],
		[str(bubble_color.g), str(bubble_color.g)],
		[parent_bubble_node.get_name(), parent_bubble_node.get_name()], 
		[bubble_interface_node.get_name(), bubble_interface_node.get_name()]
	]
	print_debug(save_array)
	thoughtbubble_store.save(timestamp, save_array)
func save_color_b(timestamp):
	var save_array = [
		["Timestamp-[%s]" % timestamp, timestamp],
		["Color", "Color"], 
		["b-color","b-color"],
		[str(bubble_color.b), str(bubble_color.b)],
		[parent_bubble_node.get_name(), parent_bubble_node.get_name()], 
		[bubble_interface_node.get_name(), bubble_interface_node.get_name()]
	]
	print_debug(save_array)
	thoughtbubble_store.save(timestamp, save_array)
func save_color_a(timestamp):
	var save_array = [
		["Timestamp-[%s]" % timestamp, timestamp],
		["Color", "Color"], 
		["a-color","a-color"],
		[str(bubble_color.a), str(bubble_color.a)],
		[parent_bubble_node.get_name(), parent_bubble_node.get_name()], 
		[bubble_interface_node.get_name(), bubble_interface_node.get_name()]
	]
	print_debug(save_array)
	thoughtbubble_store.save(timestamp, save_array)

func save_shape(timestamp):
	var save_array = [
		["Timestamp-[%s]" % timestamp, timestamp],
		["Shape", "Shape"], 
		[str(get_child(0)), str(get_child(0))],
		[parent_bubble_node.get_name(), parent_bubble_node.get_name()], 
		[bubble_interface_node.get_name(), bubble_interface_node.get_name()]
	]
	print_debug(save_array)
	thoughtbubble_store.save(timestamp, save_array)

func save_links(timestamp):
	
	for link in child_thoughts:
		
		print_debug(link)
		print_debug(bubble_interface_node.get_name() + " saving... " + link)
		var save_array = [
			["Timestamp-[%s]" % timestamp, timestamp],
			[parent_bubble_node.get_name(), parent_bubble_node.get_name()], 
			[bubble_interface_node.get_name(), bubble_interface_node.get_name()],
			[str(link.replace("../", "")), str(link.replace("../", ""))]
		]
		print_debug(save_array)
		thoughtbubble_store.save(timestamp, save_array)
		#save_bubble_property(save_array)

#endregion

#region ----------------------- Linking ----------------------- #
func new_linked_thought(new_thought):
	if (child_thoughts.find(new_thought) == -1):
		if (parent_space_node.find_child(new_thought) == null):
			var thoughts = []
			for thought in parent_thoughts:
				thoughts.append(thought)
			thoughts.append(bubble_interface_node.get_name())
			print_debug("Creating and linking " + new_thought)
			parent_space_node.create_and_link_new_thought(new_thought, thoughts, global_transform.origin)
		else:
			child_thoughts.append(new_thought)
			load_parent_links(new_thought)
			parent_space_node.get_node(new_thought).get_child(1)._load_link_nodes()
		print_debug("Link to " + str(parent_space_node.get_node(new_thought)))

#Runs on signal from thought space after all thoughts have been loaded into the scene
func _load_link_nodes():

	#clear existing link renderers
	for link in bubble_interface_node.get_child(3).get_children():
		link.free()
	#print_debug("Loading Links")
	var linked_nodes = process_links()
	if (len(linked_nodes)>0):
		for node in process_links():
			var new_link_node = link_scene.instantiate()
			bubble_interface_node.get_child(3).add_child(new_link_node)
			#print_debug(str(self) + " " + str(len(parent_thoughts)-1))
			new_link_node.bubble1 = node
			new_link_node.bubble2 = bubble_interface_node
			new_link_node.set_owner(get_viewport().get_child(0))
			new_link_node.initialize()

func process_links():
	if (len(parent_thoughts) <= 1):
		#Just render link to the thought space owner
		return [parent_bubble_node]
	
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
		var parent_thought_1 = parent_space_node.get_node(parent_thoughts[i])
		for n in range(1, len(parent_thoughts)):
			
				var parent_thought_2 = parent_space_node.get_node(parent_thoughts[n])
				if (parent_thought_1.get_name() != parent_thought_2.get_name() && parent_thought_1.get_child(1).child_thoughts.find(parent_thought_2.get_name()) != -1):
					shared_count += 1

					
		ordered_thoughts[shared_count].append(parent_thought_1.get_name())
	
	var output_thoughts = []
	for parent in ordered_thoughts[0]:
		output_thoughts.append(parent_space_node.find_child(parent))
	return output_thoughts

func clear_links():
	for link in bubble_interface_node.get_child(3).get_children():
		link.free()
#endregion

#region -----------------------  Focus  ----------------------- #
func focus():
	#Create new instance of each child
	for child in child_thoughts:
		bubble_interface_node.get_child(2).new_thought_in_space(child)
		#Check child link structure to see if it exists in other focused contexts
		parent_space_node.get_node(child).check_context()
		bubble_interface_node.get_child(2).get_node(child).translate(parent_space_node.get_node(child).transform.origin - bubble_interface_node.transform.origin - Vector3(0,-2,0))
		bubble_interface_node.get_child(2).get_node(child).get_child(1).load_focus_properties(bubble_interface_node.name)
	#Load the focused properties for each child

func unfocus():
	for child in child_thoughts:
		#print_debug("Find them all as siblings and enable all of them")
		parent_space_node.get_node(child).visible = true
		for link in parent_space_node.get_node(child).get_child(3).get_children():
			link.visible = true	
	bubble_interface_node.get_child(2).clear_scene()

func load_focus_properties(focused_thought):
	print_debug("loading properties of " + bubble_interface_node.name + ": " + focused_thought)

func check_context():
	#subtracting one because the thought space context is not considered
	var num_parents = len(parent_thoughts) - 1
	for i in range(1, len(parent_thoughts)):
		#print_debug (parent_thoughts[i] + " is focused: " + parent_space_node.get_node(parent_thoughts[i]).is_focused)
		if (parent_space_node.get_node(parent_thoughts[i]).is_focused):
			num_parents -= 1
			
	if (num_parents <= 0):
		bubble_interface_node.visible = false
		for link in bubble_interface_node.get_child(3).get_children():
			link.visible = false	
	
#endregion
