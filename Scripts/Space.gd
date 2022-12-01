tool
extends Spatial

#export(bool) var load_links setget _load_links

var MB_to_godot_path = "/run/media/cithoreal/Elements/MemoryBase/ToThoughts-Git/MB_to_godot.py"
var godot_to_nodes_path = "/run/media/cithoreal/Elements/MemoryBase/ToThoughts-Git/godot_to_nodes.py"
var thought_scene = load("res://ThoughtBubble.tscn")
signal save_thoughts(timestamp)
signal load_links
signal load_parents
signal clear_thoughts


#func _load_links(_value):
#	emit_signal("load_links")

func load_space():
	var output = []
	#Add ability to intersect or union with other thought spaces in the scene
	#Child thought spaces intersect with their parents
	#Child thought spaces can at any point be "Expanded" to union instead
	OS.execute(MB_to_godot_path, [get_parent().get_name(), "|Thought|"], true, output)
	process_thoughts(output)

func save():
	print("saving thoughts")
	var timestamp = Time.get_unix_time_from_system()
	#print(Time.get_datetime_string_from_system(true,true))
	OS.execute(godot_to_nodes_path, ["|Timestamp|", timestamp], false)
	emit_signal("save_thoughts", timestamp)


#Prep the scene to be loaded with new thoughts
func clear_scene():
	emit_signal("clear_thoughts")
	for link in get_viewport().get_child(0).get_node("Links").get_children():
		link.free()
	for node in get_children():
		node.free()

#Use the text retrieved from _start_recall to retrieve thoughts and thought properties
func process_thoughts(text_block):
	clear_scene()
	var text = text_block[0].replace("[(", "")
	text = text.replace(",)]", "")
	text = text.replace("\n", "")
	#Retrieve an intersect of the thought and "Transform" to recieve the transform numbers
	print("Creating... " + get_parent().get_name())
	for i in text.split(",), ("):
		var linked_node = i.replace("'","")
		#print("Creating... " + linked_node)
		if (linked_node != "[]"):
			load_thought(linked_node)
	emit_signal("load_parents")
	emit_signal("load_links")

	
func load_thought(thought_text):
	if thought_text != "":
		var new_bubble = thought_scene.instance()
		new_bubble.set_name(thought_text)
		add_child(new_bubble)
		new_bubble.set_owner(get_viewport().get_child(0))
		new_bubble.initialize()
		

func create_and_link_new_thought(thought_text, linking_thoughts):
	if thought_text != "":
		var new_bubble = thought_scene.instance()
		new_bubble.set_name(thought_text)
		add_child(new_bubble)
		new_bubble.set_owner(get_viewport().get_child(0))
		new_bubble.initialize()
		for thought in linking_thoughts:
			if (get_child(1).get_node(thought).child_thoughts.find(new_bubble.get_name()) == -1):
				get_child(1).get_node(thought).child_thoughts.append(new_bubble.get_name())
			if (new_bubble.parent_thoughts.find(thought) == -1):
				new_bubble.parent_thoughts.append(thought)
		new_bubble.load_link_nodes()
		
