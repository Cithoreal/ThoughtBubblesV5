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


func load_thought_properties(timestamp):
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

#func _process(_delta: float) -> void:
	#var name = get_parent().get_name()
	#var position_x = bubble_interface_node.transform.origin.x
	#var position_y = bubble_interface_node.transform.origin.y
	#var position_z = bubble_interface_node.transform.origin.z
	#var basis_xx = bubble_interface_node.transform.basis.x.x
	#var basis_xy = bubble_interface_node.transform.basis.x.y
	#var basis_xz = bubble_interface_node.transform.basis.x.z
	#var basis_yx = bubble_interface_node.transform.basis.y.x
	#var basis_yy = bubble_interface_node.transform.basis.y.y
	#var basis_yz = bubble_interface_node.transform.basis.y.z
	#var basis_zx = bubble_interface_node.transform.basis.z.x
	#var basis_zy = bubble_interface_node.transform.basis.z.y
	#var basis_zz = bubble_interface_node.transform.basis.z.z
	#var color_r = bubble_color.r
	#var color_g = bubble_color.g
	#var color_b = bubble_color.b
	#var color_a = bubble_color.a
	#var shape = str(get_child(0))
	#var links = child_thoughts
	#print_debug(name , " " , position_x , " " , position_y , " " , position_z , " " , basis_xx , " " , basis_xy , " " , basis_xz , " " , basis_yx , " " , basis_yy , " " , basis_yz , " " , basis_zx , " " , basis_zy , " " , basis_zz , " " , color_r , " " , color_g , " " , color_b , " " , color_a , " " , shape , " " , links)
	


	
func save_thought(timestamp):
	print_debug("Saving " + bubble_interface_node.get_name() + " at " + str(timestamp))
	timestamp = str(timestamp)
	#Check each value to see if it has changed before saving

	save_position(timestamp)

	return
	save_name(timestamp)

	save_basis(timestamp)
	#save_links(timestamp)
	save_color(timestamp)
	save_shape(timestamp)
	
	#Collect all meta properties
	#execute external python script and pass it the node name and each property

func save_name(timestamp):
	
	# Name
	#var dict = {"Thought":{"Text": get_parent().get_name()}}

	# Note: saves whole chain for context, probably inefficient
	# Want to update latest change timestamps for thoughtspace, should be able to just tell the thought space to update that
	

	var cypher = 'MERGE (ts:ThoughtSpace{name:"'+parent_bubble_node.get_name()+'"})'
	cypher = cypher + '\n' + 'MERGE (tb:ThoughtBubble{name:"'+bubble_interface_node.get_name()+'"})'
	cypher = cypher + '\n' + 'MERGE (:ThoughtBubble{name:"'+get_parent().get_name()+'"})'
	cypher = cypher + '\n' + 'MERGE (Name:Property{name:"Name", timestamp:"'+timestamp+'"})'
	cypher = cypher + '\n' + 'MERGE (ts)-[:CONTAINS]->(tb)'
	cypher = cypher + '\n' + 'MERGE (tb)-[:HAS]->(Name)'
	cypher = cypher + '\n' + 'MERGE (tb)-[:HAS]->(Name_val:Value{value:"'+get_parent().get_name()+'"})'

	thoughtbubble_store.save(cypher)

	print_debug("save name " + bubble_interface_node.get_name())
	
	#var save_array = [ "`Godot`", "`Thought`", "`Text`", get_parent().get_name()]
	##print_debug(save_array)
	#
	#if thoughtbubble_store.get_nodes([ "`Godot`", "`Thought`", "`Text`"]) and !thoughtbubble_store.get_nodes([ "`Godot`", "`Thought`", "`Text`"]).has(get_parent().get_name()):
		#save_bubble_property(save_array)

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


func save_basis(timestamp):
		# Basis
	var cypher = 'MERGE (ts:ThoughtSpace{name:"'+parent_bubble_node.get_name()+'"})'
	cypher = cypher + '\n' + 'MERGE (tb:ThoughtBubble{name:"'+bubble_interface_node.get_name()+'"})'
	cypher = cypher + '\n' + 'MERGE (Basis:Property{name:"Basis", timestamp:"'+timestamp+'"})'
	cypher = cypher + '\n' + 'MERGE (xx:Basis{name:"xx"})'
	cypher = cypher + '\n' + 'MERGE (xy:Basis{name:"xy"})'
	cypher = cypher + '\n' + 'MERGE (xz:Basis{name:"xz"})'
	cypher = cypher + '\n' + 'MERGE (yx:Basis{name:"yx"})'
	cypher = cypher + '\n' + 'MERGE (yy:Basis{name:"yy"})'
	cypher = cypher + '\n' + 'MERGE (yz:Basis{name:"yz"})'
	cypher = cypher + '\n' + 'MERGE (zx:Basis{name:"zx"})'
	cypher = cypher + '\n' + 'MERGE (zy:Basis{name:"zy"})'
	cypher = cypher + '\n' + 'MERGE (zz:Basis{name:"zz"})'
	cypher = cypher + '\n' + 'MERGE (ts)-[:CONTAINS]->(tb)'
	cypher = cypher + '\n' + 'MERGE (tb)-[:HAS]->(Basis)'
	cypher = cypher + '\n' + 'MERGE (tb)-[:HAS]->(xx)'
	cypher = cypher + '\n' + 'MERGE (tb)-[:HAS]->(xy)'
	cypher = cypher + '\n' + 'MERGE (tb)-[:HAS]->(xz)'
	cypher = cypher + '\n' + 'MERGE (tb)-[:HAS]->(yx)'
	cypher = cypher + '\n' + 'MERGE (tb)-[:HAS]->(yy)'
	cypher = cypher + '\n' + 'MERGE (tb)-[:HAS]->(yz)'
	cypher = cypher + '\n' + 'MERGE (tb)-[:HAS]->(zx)'
	cypher = cypher + '\n' + 'MERGE (tb)-[:HAS]->(zy)'
	cypher = cypher + '\n' + 'MERGE (tb)-[:HAS]->(zz)'
	cypher = cypher + '\n' + 'MERGE (tb)-[:HAS]->(:Value{value:"'+str(bubble_interface_node.transform.basis.x.x)+'"})'
	cypher = cypher + '\n' + 'MERGE (tb)-[:HAS]->(:Value{value:"'+str(bubble_interface_node.transform.basis.x.y)+'"})'
	cypher = cypher + '\n' + 'MERGE (tb)-[:HAS]->(:Value{value:"'+str(bubble_interface_node.transform.basis.x.z)+'"})'
	cypher = cypher + '\n' + 'MERGE (tb)-[:HAS]->(:Value{value:"'+str(bubble_interface_node.transform.basis.y.x)+'"})'
	cypher = cypher + '\n' + 'MERGE (tb)-[:HAS]->(:Value{value:"'+str(bubble_interface_node.transform.basis.y.y)+'"})'
	cypher = cypher + '\n' + 'MERGE (tb)-[:HAS]->(:Value{value:"'+str(bubble_interface_node.transform.basis.y.z)+'"})'
	cypher = cypher + '\n' + 'MERGE (tb)-[:HAS]->(:Value{value:"'+str(bubble_interface_node.transform.basis.z.x)+'"})'
	cypher = cypher + '\n' + 'MERGE (tb)-[:HAS]->(:Value{value:"'+str(bubble_interface_node.transform.basis.z.y)+'"})'
	cypher = cypher + '\n' + 'MERGE (tb)-[:HAS]->(:Value{value:"'+str(bubble_interface_node.transform.basis.z.z)+'"})'
	cypher = cypher + '\n' + 'MERGE (t3D)-[:HAS]->(xx)'
	cypher = cypher + '\n' + 'MERGE (t3D)-[:HAS]->(xy)'
	cypher = cypher + '\n' + 'MERGE (t3D)-[:HAS]->(xz)'
	cypher = cypher + '\n' + 'MERGE (t3D)-[:HAS]->(yx)'
	cypher = cypher + '\n' + 'MERGE (t3D)-[:HAS]->(yy)'
	cypher = cypher + '\n' + 'MERGE (t3D)-[:HAS]->(yz)'
	cypher = cypher + '\n' + 'MERGE (t3D)-[:HAS]->(zx)'
	cypher = cypher + '\n' + 'MERGE (t3D)-[:HAS]->(zy)'
	cypher = cypher + '\n' + 'MERGE (t3D)-[:HAS]->(zz)'
	cypher = cypher + '\n' + 'MERGE (xx)-[:HAS]->(:Value{value:"'+str(bubble_interface_node.transform.basis.x.x)+'"})'
	cypher = cypher + '\n' + 'MERGE (xy)-[:HAS]->(:Value{value:"'+str(bubble_interface_node.transform.basis.x.y)+'"})'
	cypher = cypher + '\n' + 'MERGE (xz)-[:HAS]->(:Value{value:"'+str(bubble_interface_node.transform.basis.x.z)+'"})'
	cypher = cypher + '\n' + 'MERGE (yx)-[:HAS]->(:Value{value:"'+str(bubble_interface_node.transform.basis.y.x)+'"})'
	cypher = cypher + '\n' + 'MERGE (yy)-[:HAS]->(:Value{value:"'+str(bubble_interface_node.transform.basis.y.y)+'"})'
	cypher = cypher + '\n' + 'MERGE (yz)-[:HAS]->(:Value{value:"'+str(bubble_interface_node.transform.basis.y.z)+'"})'
	cypher = cypher + '\n' + 'MERGE (zx)-[:HAS]->(:Value{value:"'+str(bubble_interface_node.transform.basis.z.x)+'"})'
	cypher = cypher + '\n' + 'MERGE (zy)-[:HAS]->(:Value{value:"'+str(bubble_interface_node.transform.basis.z.y)+'"})'
	cypher = cypher + '\n' + 'MERGE (zz)-[:HAS]->(:Value{value:"'+str(bubble_interface_node.transform.basis.z.z)+'"})'
	thoughtbubble_store.save(cypher)


	#var dict = {"Transform3D":
		#{ "Basis":
			#{ "xx": str(bubble_interface_node.transform.basis.x.x),
			#"Timestamp": timestamp
			#}
		#}
	#}
	#save_bubble_property(dict)
	#dict = {"Transform3D":
		#{ "Basis":
			#{ "xy": str(bubble_interface_node.transform.basis.x.y),
			#"Timestamp": timestamp
			#}
		#}
	#}
	#save_bubble_property(dict)
	#dict = {"Transform3D":
		#{ "Basis":
			#{ "xz": str(bubble_interface_node.transform.basis.x.z),
			#"Timestamp": timestamp
			#}
		#}
	#}
	#save_bubble_property(dict)
	
	#save_bubble_property(["`Transform3D`", "`Basis`", "`xx`", str(timestamp), str(bubble_interface_node.transform.basis.x.x)])
	#save_bubble_property(["`Transform3D`", "`Basis`", "`xy`", str(timestamp), str(bubble_interface_node.transform.basis.x.y)])
	#save_bubble_property(["`Transform3D`", "`Basis`", "`xz`", str(timestamp), str(bubble_interface_node.transform.basis.x.z)])
	


	#dict = {"Transform3D":
		#{ "Basis":
			#{ "yx": str(bubble_interface_node.transform.basis.y.x),
			#"Timestamp": timestamp
			#}
		#}
	#}
	#save_bubble_property(dict)
	#dict = {"Transform3D":
		#{ "Basis":
			#{ "yy": str(bubble_interface_node.transform.basis.y.y),
			#"Timestamp": timestamp
			#}
		#}
	#}
	#save_bubble_property(dict)
	#dict = {"Transform3D":
		#{ "Basis":
			#{ "yz": str(bubble_interface_node.transform.basis.y.z),
			#"Timestamp": timestamp
			#}
		#}
	#}
	#save_bubble_property(dict)
	#
	##save_bubble_property(["`Transform3D`", "`Basis`", "`yx`", str(timestamp), str(bubble_interface_node.transform.basis.y.x)])
	##save_bubble_property(["`Transform3D`", "`Basis`", "`yy`", str(timestamp), str(bubble_interface_node.transform.basis.y.y)])
	##save_bubble_property(["`Transform3D`", "`Basis`", "`yz`", str(timestamp), str(bubble_interface_node.transform.basis.y.z)])
#
#
	#dict = {"Transform3D":
		#{ "Basis":
			#{ "zx": str(bubble_interface_node.transform.basis.z.x),
			#"Timestamp": timestamp
			#}
		#}
	#}
	#save_bubble_property(dict)
	#dict = {"Transform3D":
		#{ "Basis":
			#{ "zy": str(bubble_interface_node.transform.basis.z.y),
			#"Timestamp": timestamp
			#}
		#}
	#}
	#save_bubble_property(dict)
	#dict = {"Transform3D":
		#{ "Basis":
			#{ "zz": str(bubble_interface_node.transform.basis.z.z),
			#"Timestamp": timestamp
			#}
		#}
	#}
	#save_bubble_property(dict)
	
	#save_bubble_property(["`Transform3D`", "`Basis`", "`zx`", str(timestamp), str(bubble_interface_node.transform.basis.z.x)])
	#save_bubble_property(["`Transform3D`", "`Basis`", "`zy`", str(timestamp), str(bubble_interface_node.transform.basis.z.y)])
	#save_bubble_property(["`Transform3D`", "`Basis`", "`zz`", str(timestamp), str(bubble_interface_node.transform.basis.z.z)])

func save_color(timestamp):
	# Color
	var cypher = 'MERGE (ts:ThoughtSpace{name:"'+parent_bubble_node.get_name()+'"})'
	cypher = cypher + '\n' + 'MERGE (tb:ThoughtBubble{name:"'+bubble_interface_node.get_name()+'"})'
	cypher = cypher + '\n' + 'MERGE (Color:Property{name:"color", timestamp:"'+timestamp+'"})'
	cypher = cypher + '\n' + 'MERGE (r:Color{name:"r"})'
	cypher = cypher + '\n' + 'MERGE (g:Color{name:"g"})'
	cypher = cypher + '\n' + 'MERGE (b:Color{name:"b"})'
	cypher = cypher + '\n' + 'MERGE (a:Color{name:"a"})'
	cypher = cypher + '\n' + 'MERGE (Color)-[:HAS]->(r)'
	cypher = cypher + '\n' + 'MERGE (Color)-[:HAS]->(g)'
	cypher = cypher + '\n' + 'MERGE (Color)-[:HAS]->(b)'
	cypher = cypher + '\n' + 'MERGE (Color)-[:HAS]->(a)'
	cypher = cypher + '\n' + 'MERGE (ts)-[:CONTAINS]->(tb)'
	cypher = cypher + '\n' + 'MERGE (tb)-[:HAS]->(Color)'
	cypher = cypher + '\n' + 'MERGE (tb)-[:HAS]->(r)'
	cypher = cypher + '\n' + 'MERGE (tb)-[:HAS]->(g)'
	cypher = cypher + '\n' + 'MERGE (tb)-[:HAS]->(b)'
	cypher = cypher + '\n' + 'MERGE (tb)-[:HAS]->(a)'
	cypher = cypher + '\n' + 'MERGE (r)-[:HAS]->(r_val:Value{value:"'+str(bubble_color.r)+'"})'
	cypher = cypher + '\n' + 'MERGE (g)-[:HAS]->(g_val:Value{value:"'+str(bubble_color.g)+'"})'
	cypher = cypher + '\n' + 'MERGE (b)-[:HAS]->(b_val:Value{value:"'+str(bubble_color.b)+'"})'
	cypher = cypher + '\n' + 'MERGE (a)-[:HAS]->(a_val:Value{value:"'+str(bubble_color.a)+'"})'
	thoughtbubble_store.save(cypher)
	
	# var dict = {"Material":
	# 	{ "Color":
	# 		{ "r": str(bubble_color.r),
	# 		"Timestamp": timestamp
	# 		}
	# 	}
	# }
	# save_bubble_property(dict)
	
	# dict = {"Material":
	# 	{ "Color":
	# 		{ "g": str(bubble_color.g),
	# 		"Timestamp": timestamp
	# 		}
	# 	}
	# }
	# save_bubble_property(dict)
	
	# dict = {"Material":
	# 	{ "Color":
	# 		{ "b": str(bubble_color.b),
	# 		"Timestamp": timestamp
	# 		}
	# 	}
	# }
	# save_bubble_property(dict)
	
	# dict = {"Material":
	# 	{ "Color":
	# 		{ "a": str(bubble_color.a),
	# 		"Timestamp": timestamp
	# 		}
	# 	}
	# }
	# save_bubble_property(dict)
	#save_bubble_property(["`Material`", "`Color`", "`r`", str(timestamp), str(bubble_color.r)])
	#save_bubble_property(["`Material`", "`Color`", "`g`", str(timestamp), str(bubble_color.g)])
	#save_bubble_property(["`Material`", "`Color`", "`b`", str(timestamp), str(bubble_color.b)])
	#save_bubble_property(["`Material`", "`Color`", "`a`", str(timestamp), str(bubble_color.a)])

func save_shape(timestamp):
	var cypher = 'MERGE (ts:ThoughtSpace{name:"'+parent_bubble_node.get_name()+'"})'
	cypher = cypher + '\n' + 'MERGE (tb:ThoughtBubble{name:"'+bubble_interface_node.get_name()+'"})'
	cypher = cypher + '\n' + 'MERGE (Shape:Property{name:"Shape", timestamp:"'+timestamp+'"})'
	cypher = cypher + '\n' + 'MERGE (s:Shape{name:"'+str(get_child(0))+'"})'
	cypher = cypher + '\n' + 'MERGE (ts)-[:CONTAINS]->(tb)'
	cypher = cypher + '\n' + 'MERGE (tb)-[:HAS]->(Shape)'
	cypher = cypher + '\n' + 'MERGE (tb)-[:HAS]->(s)'
	cypher = cypher + '\n' + 'MERGE (tb)-[:HAS]->(:Value{value:"'+str(get_child(0))+'"})'
	cypher = cypher + '\n' + 'MERGE (Shape)-[:HAS]->(s)'
	cypher = cypher + '\n' + 'MERGE (s)-[:HAS]->(:Value{value:"'+str(get_child(0))+'"})'
	thoughtbubble_store.save(cypher)
	# var dict = {"`Shape`": str(get_child(0)), "Timestamp": timestamp}
	# save_bubble_property(dict)
	print_debug("possibly all saved")
	
# func save_bubble_property(propertyDict):
# 	#if (get_latest_bubble_property_value(property, element) != value && value != ""):
# 		#print_debug(get_parent().get_name())
# 		#var save_dict = {"ThoughtSpace":[parent_bubble_node.get_name(),{"ThoughtBubble":[bubble_interface_node.get_name(),{"Properties":propertyDict}]}]}
# 		var cypher = 'MERGE (ts:ThoughtSpace{name:"'+parent_bubble_node.get_name()+'"})'
# 		cypher = cypher + '\n' + 'MERGE (tb:ThoughtBubble{name:"'+bubble_interface_node.get_name()+'"})'
# 		cypher = cypher + '\n' + propertyDict
# 		thoughtbubble_store.save(cypher)



func save_links(timestamp):
	
	for link in child_thoughts:
		
		print_debug(link)
		print_debug(bubble_interface_node.get_name() + " saving... " + link)
		var dict = {parent_bubble_node.get_name():{"Link":str(link.replace("../", "")),"Timestamp":timestamp}}
		var save_array = dict
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
