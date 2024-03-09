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
var file_manager

# ----------------------- INITIALIZATION ----------------------- #
#region Initialization
func _enter_tree():
	
	bubble_interface_node = get_parent()
	parent_space_node = get_parent().get_parent()
	parent_bubble_node = get_parent().get_parent().get_parent()
	file_manager = get_viewport().get_child(0).get_node("FileManager")
	#Check if parent node is "Space" and not "Scene" to ensure this bubble is not top level
	if (parent_space_node.get_name() != get_viewport().get_child(0).get_name()):
		#print("signals connected")
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
			#print("Sphere")
			new_shape = CSGSphere3D.new()
			new_shape.radius = .623
			new_shape.radial_segments = 16
			new_shape.rings = 16
			get_child(0).get_child(0).shape = SphereShape3D
			#get_parent().shape = 0
		1:
			#print("Cube")
			new_shape = CSGBox3D.new()
			get_child(0).get_child(0).shape = BoxShape3D
			#get_parent().shape = 1
		2:
			#print("Cylinder")
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
# ----------------------- Loading ----------------------- #
#region Loading
func load_thought_properties(timestamp):
	#print(str(Time.get_time_string_from_system()) + ": Loading " + bubble_interface_node.get_name())
	var thread1 = Thread.new()
	var thread2 = Thread.new()
	var thread3 = Thread.new()
	var thread4 = Thread.new()
	var callable = Callable(self, "load_position")
	callable = callable.bind(timestamp)
	thread1.start(callable,Thread.PRIORITY_NORMAL)

	callable = Callable(self, "load_shape")
	callable = callable.bind(timestamp)
	thread4.start(callable,Thread.PRIORITY_NORMAL)

	#load_position(timestamp)
	#print(str(Time.get_time_string_from_system()) + ": " + bubble_interface_node.get_name() + " After Position")
	callable = Callable(self, "load_color")
	callable = callable.bind(timestamp)
	thread2.start(callable,Thread.PRIORITY_NORMAL)
	#load_color(timestamp)
	#print(str(Time.get_time_string_from_system()) + ": " + bubble_interface_node.get_name() + " After Color")
	callable = Callable(self, "load_links")
	callable = callable.bind(timestamp)
	thread3.start(callable,Thread.PRIORITY_NORMAL)
	#load_links(timestamp)
	#print(str(Time.get_time_string_from_system()) + ": " + bubble_interface_node.get_name() + " After Links")
	
	#load_shape(timestamp)


func load_position(timestamp):
	timestamp = str(timestamp)
	var x = ""
	var y = ""
	var z = ""
	#print(bubble_interface_node.get_name() + " loading position")
	x = get_bubble_property(["`Position`" ,"`x`"], timestamp)
	y = get_bubble_property(["`Position`", "`y`"], timestamp)
	z = get_bubble_property(["`Position`", "`z`"], timestamp)
	#print(x,",",y,",",z)
	x = x[len(x)-1]
	y = y[len(y)-1]
	z = z[len(z)-1]
	
	#print(x,",",y,",",z)
	#print(x)
	#print(bubble_interface_node.get_name() + ": " + str(Vector3(float(x),float(y),float(z))))
	if (x == ""):
		x = 0
	if (y == ""):
		y = 0
	if (z == ""):
		z = 0
	#print(Vector3(float(x),float(y),float(z)))
	bubble_interface_node.transform.origin = Vector3(float(x),float(y),float(z))
	
func load_color(timestamp):
	var r = ""
	var g = ""
	var b = ""
	var a = ""

	r = get_bubble_property(["`Color`", "`r`"], str(timestamp))
	g = get_bubble_property(["`Color`", "`g`"], str(timestamp))
	b = get_bubble_property(["`Color`", "`b`"], str(timestamp))
	a = get_bubble_property(["`Color`", "`a`"], str(timestamp))
	r = r[len(r)-1]
	g = g[len(g)-1]
	b = b[len(b)-1]
	a = a[len(a)-1]
	if (r == "" || g == "" || b == "" || a == ""):
		bubble_color = Color(0.329412, 0.517647, 0.6, 0.533333)
	else:
		r = float(r)
		g = float(g)
		b = float(b)
		a = float(a)
		bubble_color = Color(r,g,b,a)
	get_child(0).material_override.albedo_color = bubble_color
	bubble_interface_node.bubble_color  = bubble_color

func load_shape(timestamp):

	timestamp = str(timestamp)
	var shape = get_bubble_property(["`Shape`"], timestamp)
	shape = shape[len(shape)-1]
	var shape_id = 0
	match shape:
		"CSGSphere3D":
			shape_id = 0
		"CSGBox3D":
			shape_id = 1
		"CSGCylinder3D":
			shape_id = 2
	get_parent().shape = shape_id
			
func load_links(timestamp):
	#Find and use proper timestamp
#	var get_array = file_manager.get_from_orbitdb([parent_bubble_node.get_name(),bubble_interface_node.get_name(), "`Link`"])
	var links = get_bubble_property([parent_bubble_node.get_name(),bubble_interface_node.get_name(), "`Link`"],timestamp)
	print(links)
	for link in links:
		if (link != ""):
			child_thoughts.append(link)
#	var timestamps = file_manager.get_from_orbitdb(["`Timestamp`"])
#	if (get_array[0] != ""):
#		#print(get_parent().get_name(), " ", get_array)
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


#func get_bubble_property(property_array, timestamp):
#	var focused = false
#
#	var output = []
#	var load_array = [bubble_interface_node.get_name()]#, loaded_nodes["`"+property+"`"], loaded_nodes["`"+element+"`"], loaded_nodes["`Timestamp`"]]
#	load_array.append_array(property_array)
#	load_array.append("`Timestamp`")
#	output = file_manager.get_from_orbitdb(load_array)
#
#	#print(load_array)
#	#print(output)
#	if (!output.has(timestamp)):
#		#Ensure this is the closest timestamp to the selected as possible
#		for time in output:
#			if (float(time) < float(timestamp)):
#				timestamp = time
#	#print(output)		
#	#print(timestamp)	
#	if (output.find(timestamp) > -1):
#		load_array.pop_back()
#		load_array.append(str(timestamp))
#		#load_array = [loaded_nodes[bubble_interface_node.get_name()], loaded_nodes["`" + property + "`"], loaded_nodes["`" + element + "`"], loaded_nodes[str(timestamp)]]
#		#print(load_array)
#		output = file_manager.get_from_orbitdb(load_array)
#		#print(output)
#		if (len(output) > 0):
#			return output[len(output)-1]
#		else:
#			return null
#	else:
#		print("Remember to set the timestamp")
#		bubble_interface_node.visible = false
func get_bubble_property(property_array, timestamp):

	var output = []
	var load_array = [bubble_interface_node.get_name()]#, loaded_nodes["`"+property+"`"], loaded_nodes["`"+element+"`"], loaded_nodes["`Timestamp`"]]
	load_array.append_array(property_array)
	load_array.append("`Timestamp`")
	output = file_manager.get_from_orbitdb(load_array)
	#var back_timestamps = file_manager.get_from_orbitdb([timestamp], "`BackLink`")
	#print(back_timestamps)
	print(output)
	if (!output.has(timestamp)):
		#Ensure this is the closest timestamp to the selected as possible
		for time in output:
			if (float(time) < float(timestamp)):
				timestamp = time
	#print(output)		
	#print(timestamp)	
	if (output.find(timestamp) > -1):
		load_array.pop_back()
		load_array.append(str(timestamp))
		#load_array = [loaded_nodes[bubble_interface_node.get_name()], loaded_nodes["`" + property + "`"], loaded_nodes["`" + element + "`"], loaded_nodes[str(timestamp)]]
		#print(load_array)
		output = file_manager.get_from_orbitdb(load_array)
		if (output.has(str(timestamp))):
			output.remove_at(output.find(str(timestamp)))
		if (len(output) > 0):
			return output
		else:
			return null
	else:
		print("Remember to set the timestamp")
		bubble_interface_node.visible = false
#endregion
# ----------------------- Saving ----------------------- #
#region Saving
func save_thought(timestamp):

	var thread = Thread.new()
	var callable = Callable(self, "_save_thought")
	callable = callable.bind(timestamp)
	thread.start(callable,Thread.PRIORITY_NORMAL)
	
func _save_thought(timestamp):

	timestamp = str(timestamp)
	#Check each value to see if it has changed before saving
	var thread1 = Thread.new()
	var thread2 = Thread.new()
	var thread3 = Thread.new()
	var thread4 = Thread.new()
	var thread5 = Thread.new()
	var thread6 = Thread.new()
	var callable = Callable(self, "save_name")
	callable = callable.bind(timestamp)
	thread1.start(callable,Thread.PRIORITY_NORMAL)

	callable = Callable(self, "save_position")
	callable = callable.bind(timestamp)
	thread2.start(callable,Thread.PRIORITY_NORMAL)

	callable = Callable(self, "save_basis")
	callable = callable.bind(timestamp)
	thread3.start(callable,Thread.PRIORITY_NORMAL)
	
	callable = Callable(self, "save_links")
	callable = callable.bind(timestamp)
	thread4.start(callable,Thread.PRIORITY_NORMAL)
	
	callable = Callable(self, "save_color")
	callable = callable.bind(timestamp)
	thread5.start(callable,Thread.PRIORITY_NORMAL)
	
	callable = Callable(self, "save_shape")
	callable = callable.bind(timestamp)
	thread6.start(callable,Thread.PRIORITY_NORMAL)
	#save_name(timestamp)
	#save_position(timestamp)
	#save_basis(timestamp)
	#save_links(timestamp)
	#save_color(timestamp)
	#save_shape(timestamp)
	
	#Collect all meta properties
	#execute external python script and pass it the node name and each property

func save_name(timestamp):
	
	# Name

	print("save name " + bubble_interface_node.get_name())
	
	var save_array = [ "`Godot`", "`Thought`", "`Text`", get_parent().get_name()]
	#print(save_array)
	
	if !file_manager.get_from_orbitdb([ "`Godot`", "`Thought`", "`Text`"]).has(get_parent().get_name()):
		save_bubble_property(save_array)


func save_position(timestamp):
	# Position
	var thread = Thread.new()
	var callable = Callable(self, "save_bubble_property")
	callable = callable.bind(["`Transform3D`", "`Position`", "`x`", str(timestamp), str(bubble_interface_node.transform.origin.x)])
	thread.start(callable,Thread.PRIORITY_NORMAL)
	thread = Thread.new()
	callable = Callable(self, "save_bubble_property")
	callable = callable.bind(["`Transform3D`", "`Position`", "`y`", str(timestamp), str(bubble_interface_node.transform.origin.y)])
	thread.start(callable,Thread.PRIORITY_NORMAL)
	thread = Thread.new()
	callable = Callable(self, "save_bubble_property")
	callable = callable.bind(["`Transform3D`", "`Position`", "`z`", str(timestamp), str(bubble_interface_node.transform.origin.z)])
	thread.start(callable,Thread.PRIORITY_NORMAL)
	
	#save_bubble_property(["`Transform3D`", "`Position`", "`x`", str(timestamp), str(bubble_interface_node.transform.origin.x)])
	#save_bubble_property(["`Transform3D`", "`Position`", "`y`", str(timestamp), str(bubble_interface_node.transform.origin.y)])
	#save_bubble_property(["`Transform3D`", "`Position`", "`z`", str(timestamp), str(bubble_interface_node.transform.origin.z)])

func save_basis(timestamp):
		# Basis
	var thread = Thread.new()
	var callable = Callable(self, "save_bubble_property")
	callable = callable.bind(["`Transform3D`", "`Basis`", "`xx`", str(timestamp), str(bubble_interface_node.transform.basis.x.x)])
	thread.start(callable,Thread.PRIORITY_NORMAL)
	thread = Thread.new()
	callable = Callable(self, "save_bubble_property")
	callable = callable.bind(["`Transform3D`", "`Basis`", "`xy`", str(timestamp), str(bubble_interface_node.transform.basis.x.y)])
	thread.start(callable,Thread.PRIORITY_NORMAL)
	thread = Thread.new()
	callable = Callable(self, "save_bubble_property")
	callable = callable.bind(["`Transform3D`", "`Basis`", "`xz`", str(timestamp), str(bubble_interface_node.transform.basis.x.z)])
	thread.start(callable,Thread.PRIORITY_NORMAL)
	
	#save_bubble_property(["`Transform3D`", "`Basis`", "`xx`", str(timestamp), str(bubble_interface_node.transform.basis.x.x)])
	#save_bubble_property(["`Transform3D`", "`Basis`", "`xy`", str(timestamp), str(bubble_interface_node.transform.basis.x.y)])
	#save_bubble_property(["`Transform3D`", "`Basis`", "`xz`", str(timestamp), str(bubble_interface_node.transform.basis.x.z)])
	
	thread = Thread.new()
	callable = Callable(self, "save_bubble_property")
	callable = callable.bind(["`Transform3D`", "`Basis`", "`yx`", str(timestamp), str(bubble_interface_node.transform.basis.y.x)])
	thread.start(callable,Thread.PRIORITY_NORMAL)
	thread = Thread.new()
	callable = Callable(self, "save_bubble_property")
	callable = callable.bind(["`Transform3D`", "`Basis`", "`yy`", str(timestamp), str(bubble_interface_node.transform.basis.y.y)])
	thread.start(callable,Thread.PRIORITY_NORMAL)
	thread = Thread.new()
	callable = Callable(self, "save_bubble_property")
	callable = callable.bind(["`Transform3D`", "`Basis`", "`yz`", str(timestamp), str(bubble_interface_node.transform.basis.y.z)])
	thread.start(callable,Thread.PRIORITY_NORMAL)
	
	#save_bubble_property(["`Transform3D`", "`Basis`", "`yx`", str(timestamp), str(bubble_interface_node.transform.basis.y.x)])
	#save_bubble_property(["`Transform3D`", "`Basis`", "`yy`", str(timestamp), str(bubble_interface_node.transform.basis.y.y)])
	#save_bubble_property(["`Transform3D`", "`Basis`", "`yz`", str(timestamp), str(bubble_interface_node.transform.basis.y.z)])
	thread = Thread.new()
	callable = Callable(self, "save_bubble_property")
	callable = callable.bind(["`Transform3D`", "`Basis`", "`zx`", str(timestamp), str(bubble_interface_node.transform.basis.z.x)])
	thread.start(callable,Thread.PRIORITY_NORMAL)
	thread = Thread.new()
	callable = Callable(self, "save_bubble_property")
	callable = callable.bind(["`Transform3D`", "`Basis`", "`zy`", str(timestamp), str(bubble_interface_node.transform.basis.z.y)])
	thread.start(callable,Thread.PRIORITY_NORMAL)
	thread = Thread.new()
	callable = Callable(self, "save_bubble_property")
	callable = callable.bind(["`Transform3D`", "`Basis`", "`zz`", str(timestamp), str(bubble_interface_node.transform.basis.z.z)])
	thread.start(callable,Thread.PRIORITY_NORMAL)
	
	#save_bubble_property(["`Transform3D`", "`Basis`", "`zx`", str(timestamp), str(bubble_interface_node.transform.basis.z.x)])
	#save_bubble_property(["`Transform3D`", "`Basis`", "`zy`", str(timestamp), str(bubble_interface_node.transform.basis.z.y)])
	#save_bubble_property(["`Transform3D`", "`Basis`", "`zz`", str(timestamp), str(bubble_interface_node.transform.basis.z.z)])

func save_color(timestamp):
	# Color
	var thread = Thread.new()
	var callable = Callable(self, "save_bubble_property")
	callable = callable.bind(["`Material`", "`Color`", "`r`", str(timestamp), str(bubble_color.r)])
	thread.start(callable,Thread.PRIORITY_NORMAL)
	
	thread = Thread.new()
	callable = Callable(self, "save_bubble_property")
	callable = callable.bind(["`Material`", "`Color`", "`g`", str(timestamp), str(bubble_color.g)])
	thread.start(callable,Thread.PRIORITY_NORMAL)
	
	thread = Thread.new()
	callable = Callable(self, "save_bubble_property")
	callable = callable.bind(["`Material`", "`Color`", "`b`", str(timestamp), str(bubble_color.b)])
	thread.start(callable,Thread.PRIORITY_NORMAL)
	
	thread = Thread.new()
	callable = Callable(self, "save_bubble_property")
	callable = callable.bind(["`Material`", "`Color`", "`a`", str(timestamp), str(bubble_color.a)])
	thread.start(callable,Thread.PRIORITY_NORMAL)
	#save_bubble_property(["`Material`", "`Color`", "`r`", str(timestamp), str(bubble_color.r)])
	#save_bubble_property(["`Material`", "`Color`", "`g`", str(timestamp), str(bubble_color.g)])
	#save_bubble_property(["`Material`", "`Color`", "`b`", str(timestamp), str(bubble_color.b)])
	#save_bubble_property(["`Material`", "`Color`", "`a`", str(timestamp), str(bubble_color.a)])

func save_shape(timestamp):
	save_bubble_property(["`Shape`", str(timestamp), str(get_child(0).get_class())])
	print("possibly all saved")
	
func save_bubble_property(propertyArr):
	#if (get_latest_bubble_property_value(property, element) != value && value != ""):
		
		#print(get_parent().get_name())
		var save_array = ["`Godot`", "`Bubble`", parent_bubble_node.get_name(), bubble_interface_node.get_name()] #, "`" + field + "`", "`" + property + "`", "`" + element + "`", str(timestamp), value]
		for property in propertyArr:
			save_array.append(property)
		file_manager.save(save_array)
		
#func save_bubble_property(propertyArr):
#	#if (get_latest_bubble_property_value(property, element) != value && value != ""):
#
#		#print(get_parent().get_name())
#		var save_array = ["`Godot`", "`Bubble`", parent_bubble_node.get_name(), bubble_interface_node.get_name()] #, "`" + field + "`", "`" + property + "`", "`" + element + "`", str(timestamp), value]
#		for property in propertyArr:
#			save_array.append(property)
#		#print(save_array, save_array.slice(0,-2) ,save_array[-1])
#		var selector = bubble_interface_node.get_parent().timestamp_selector
#
#		# Check if each timestamp going in reverse time for latest save data 
#		# When one is found, check if the data being saved is the same, if not then save values new
#		# When found, if is the same as current values, do not save. Values will be loaded from that same prior timestamp
#		# If the list ends, save values new
#		for n in range(selector,0,-1):
#
#			var get_array = save_array.slice(0,-2)
#			get_array.append(bubble_interface_node.get_parent().timestamp_list[n])
#			print (get_array)
#			var get = file_manager.get_from_orbitdb(get_array)
#			print(get)
#			if get.has(str(save_array[-1])):
#				print("if", get)
#				#if same, exit and don't save
#				return
#			elif get[0] != "":
#				print("elif: ", get)
#				#print("Saving... ", save_array)
#
#				file_manager.save(save_array)
#				#print(file_manager.get_from_orbitdb(get_array))
#				return
#		#Save
#		#print("Saving... ", save_array)
#
#		file_manager.save(save_array)



func save_links(timestamp):
	
	for link in child_thoughts:
		
		print(link)
		print(bubble_interface_node.get_name() + " saving... " + link)
		var save_array = [ "`Godot`", bubble_interface_node.get_name(), "`Link`", str(timestamp), str(link).replace("../", "")]
		save_bubble_property(save_array)

#endregion
# ----------------------- Linking ----------------------- #
#region Linking
func new_linked_thought(new_thought):
	if (child_thoughts.find(new_thought) == -1):
		if (parent_space_node.find_child(new_thought) == null):
			var thoughts = []
			for thought in parent_thoughts:
				thoughts.append(thought)
			thoughts.append(bubble_interface_node.get_name())
			print("Creating and linking " + new_thought)
			parent_space_node.create_and_link_new_thought(new_thought, thoughts, global_transform.origin)
		else:
			child_thoughts.append(new_thought)
			load_parent_links(new_thought)
			parent_space_node.get_node(new_thought).get_child(1)._load_link_nodes()
		print("Link to " + str(parent_space_node.get_node(new_thought)))

#Runs on signal from thought space after all thoughts have been loaded into the scene
func _load_link_nodes():

	#clear existing link renderers
	for link in bubble_interface_node.get_child(3).get_children():
		link.free()
	#print("Loading Links")
	var linked_nodes = process_links()
	if (len(linked_nodes)>0):
		for node in process_links():
			var new_link_node = link_scene.instantiate()
			bubble_interface_node.get_child(3).add_child(new_link_node)
			#print(str(self) + " " + str(len(parent_thoughts)-1))
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
# ----------------------- Focus ----------------------- #
#region Focus
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
		#print("Find them all as siblings and enable all of them")
		parent_space_node.get_node(child).visible = true
		for link in parent_space_node.get_node(child).get_child(3).get_children():
			link.visible = true	
	bubble_interface_node.get_child(2).clear_scene()

func load_focus_properties(focused_thought):
	print("loading properties of " + bubble_interface_node.name + ": " + focused_thought)

func check_context():
	#subtracting one because the thought space context is not considered
	var num_parents = len(parent_thoughts) - 1
	for i in range(1, len(parent_thoughts)):
		#print (parent_thoughts[i] + " is focused: " + parent_space_node.get_node(parent_thoughts[i]).is_focused)
		if (parent_space_node.get_node(parent_thoughts[i]).is_focused):
			num_parents -= 1
			
	if (num_parents <= 0):
		bubble_interface_node.visible = false
		for link in bubble_interface_node.get_child(3).get_children():
			link.visible = false	
	
#endregion
