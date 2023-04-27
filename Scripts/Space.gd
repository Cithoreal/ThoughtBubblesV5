@tool
extends Node3D

#export var load_links: bool : set = _load_links

var MB_to_godot_path = "/run/media/cithoreal/Elements/MemoryBase/ToThoughts-Git/MB_to_godot.py"
var godot_to_nodes_path = "/run/media/cithoreal/Elements/MemoryBase/ToThoughts-Git/godot_to_nodes.py"
var thought_scene = load("res://Scenes/ThoughtBubble.tscn")
signal save_thoughts(timestamp)
signal load_links
signal load_parents

var file_manager

#func _load_links(_value):
#	emit_signal("load_links")
#var thread

#func _ready():
	
	
#func _exit_tree():
#	thread.wait_to_finish()

func load_timestamps(selector):
	file_manager = get_viewport().get_child(0).get_node("FileManager")
	var loaded_nodes = file_manager.load_file()
	var output = loaded_nodes["|Timestamp|"]
	return output[selector]
	
#Generated by Bing Chat
func getIntersection(arrays):
	var intersection = []
	for item in arrays[0]:
		var exists = true
		for i in range(1, arrays.size()):
			if !arrays[i].has(item):
				exists = false
				break
		if exists:
			intersection.append(item)
	return intersection
	
func load_space():
	file_manager = get_viewport().get_child(0).get_node("FileManager")
	var loaded_nodes = file_manager.load_file()
	#print(loaded_nodes)
	#Add ability to intersect or union with other thought spaces in the scene
	#Child thought spaces intersect with their parents
	#Child thought spaces can at any point be "Expanded" to union instead
	#print(str(Time.get_time_string_from_system()) + ": Thought Space before Execute()")
	clear_scene()

	
	
	for node in loaded_nodes["|Text|"]:
		#print(node)
		load_thought(node)
		
	emit_signal("load_links")
	emit_signal("load_parents")
	#OS.execute(MB_to_godot_path, [get_parent().get_name(), "|Thought|"], true, output)
	#print(str(Time.get_time_string_from_system()) + ": Thought Space after Execute()")
	#process_thoughts(output)
	
func save():
	print("saving thoughts")
	var timestamp = Time.get_unix_time_from_system()
	file_manager = get_viewport().get_child(0).get_node("FileManager")
	var space_dict = {}
	for node in get_children():
		space_dict[node.get_name()] = node.get_child_thoughts()

	file_manager.save(space_dict)
	#print(Time.get_datetime_string_from_system(true,true))
	file_manager.save({"|Timestamp|": [str(timestamp)]})
	#OS.execute(godot_to_nodes_path, [get_parent().get_name(), "|Timestamp|", timestamp], false)
	#OS.execute(godot_to_nodes_path, ["|Space|", "|Thought|", get_parent().get_name()], false)
	emit_signal("save_thoughts", timestamp)


#Prep the scene to be loaded with new thoughts
func clear_scene():
	for node in get_children():
		node.get_child(1).clear_links()
		node.free()
	
func load_thought(thought_text):
	if thought_text != "":
		var new_bubble = thought_scene.instantiate()
		new_bubble.set_name(thought_text)
		add_child(new_bubble)
		new_bubble.set_owner(get_viewport().get_child(0))
		new_bubble.initialize()
		new_bubble.get_child(1).load_thought_properties(get_parent().current_timestamp)
		

func create_and_link_new_thought(thought_text, linking_thoughts, position):
	if thought_text != "":
		var new_bubble = thought_scene.instantiate()
		new_bubble.set_name(thought_text)
		add_child(new_bubble)
		new_bubble.set_owner(get_viewport().get_child(0))
		new_bubble.initialize()
		new_bubble.translate(position)
		new_bubble.translate(Vector3(0,-2,0))
		
		for thought in linking_thoughts:
			if (thought != get_parent().get_name()):
				if (get_node(thought).get_child(1).child_thoughts.find(new_bubble.get_name()) == -1):
					get_node(thought).get_child(1).child_thoughts.append(new_bubble.get_name())
				if (new_bubble.get_child(1).parent_thoughts.find(thought) == -1):
					new_bubble.get_child(1).parent_thoughts.append(thought)
				
		new_bubble.get_child(1)._load_link_nodes()

func new_thought_in_space(thought_text):
	if thought_text != "":
		var new_bubble = thought_scene.instantiate()
		new_bubble.set_name(thought_text)
		add_child(new_bubble)
		new_bubble.set_owner(get_viewport().get_child(0))
		new_bubble.initialize()
		new_bubble.get_child(1)._load_link_nodes()
		new_bubble.translate(Vector3(0,-2,0))
		


func test(test_var):
	file_manager = get_viewport().get_child(0).get_node("FileManager")
	file_manager.connect("orbitdb_recieved", Callable(self, "test_get_signal"))
	file_manager.get_from_orbitdb(test_var)
	
func test_get_signal(test_var):
	print(test_var)
	var fixed_var = ""
	file_manager = get_viewport().get_child(0).get_node("FileManager")
	file_manager.disconnect("orbitdb_recieved", Callable(self, "test_get_signal"))
	fixed_var = test_var.replace("\'","\"")
	var dict = JSON.parse_string(fixed_var)
	print(dict)
	print(dict["5"])

