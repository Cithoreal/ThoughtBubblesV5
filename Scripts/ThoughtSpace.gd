tool
extends Spatial

export(bool) var load_collection setget _start_recall
export(bool) var save_thoughts setget _save
export var thought_collection = ""
export var new_thought = ""
export(bool) var create_new_thought setget _on_new_thought_button
export(bool) var run_functions = false
var MB_to_godot_path = "/run/media/cithoreal/Elements/MemoryBase/ToThoughts-Git/MB_to_godot.py"
var godot_to_nodes_path = "/run/media/cithoreal/Elements/MemoryBase/ToThoughts-Git/godot_to_nodes.py"
var thought_scene = load("res://ThoughtBubble.tscn")

signal save_thoughts
signal clear_thoughts

func _start_recall(_value):
	if (len(thought_collection) > 0 && run_functions):
		var output = []
		OS.execute(MB_to_godot_path, [thought_collection, "|Thought|"], true, output)
		#process_thoughts(output)

func _save(_value):
	if (run_functions):
		print("saving thoughts")
		emit_signal("save_thoughts")
		#OS.execute(godot_to_nodes_path, [], false)

#Prep the scene to be loaded with new thoughts
func clear_scene():
	emit_signal("clear_thoughts")
	for link in get_child(0).get_children():
		link.free()
	for node in get_child(1).get_children():
		node.free()
	pass

#Use the text retrieved from _start_recall to retrieve thoughts and thought properties
func process_thoughts(text_block):
	clear_scene()
	var text = text_block[0].replace("[(", "")
	text = text.replace(",)]", "")
	text = text.replace("\n", "")
	#Retrieve an intersect of the thought and "Transform" to recieve the transform numbers
	print("Creating... " + thought_collection)
	create_new_thought(thought_collection)
	for i in text.split(",), ("):
		var linked_node = i.replace("'","")
		print("Creating... " + linked_node)
		create_new_thought(linked_node)

#Instantiate links between thoughts
func load_links():
	pass

func _on_new_thought_button(_value):
	if (new_thought != "" && run_functions):
		create_new_thought(new_thought)
	
func create_new_thought(thought_text):
	if thought_text != "" && run_functions:
		var new_bubble = thought_scene.instance()
		new_bubble.set_name(thought_text)
		get_child(1).add_child(new_bubble)
		new_bubble.set_owner(get_parent())
		
