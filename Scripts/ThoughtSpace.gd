tool
extends Spatial

export(bool) var load_collection setget _start_recall
export(bool) var save_thoughts setget _save
export var thought_collection = ""
export var new_thought = ""
export(bool) var create_new_thought setget _create_new_thought
var MB_to_godot_path = "/run/media/cithoreal/Elements/MemoryBase/ToThoughts-Git/MB_to_godot.py"
var godot_to_nodes_path = "/run/media/cithoreal/Elements/MemoryBase/ToThoughts-Git/godot_to_nodes.py"
var thought_scene = load("res://ThoughtBubble.tscn")

var links_path = "Thought_Space/Links"
var thoughtbubbles_path = "Thought_Space/----Thought Bubbles----"

signal save_thoughts
signal clear_thoughts

func _start_recall(_value):
	if (thought_collection != ""):
		var output = []
		OS.execute(MB_to_godot_path, [thought_collection], true, output)
		process_thoughts(output)

func _save(_value):
	print("saving thoughts")
	emit_signal("save_thoughts")
	#OS.execute(godot_to_nodes_path, [], false)

#Prep the scene to be loaded with new thoughts
func clear_scene():
	emit_signal("clear_thoughts")
	for link in get_node(links_path).get_children():
		link.queue_free()
	for node in get_node(thoughtbubbles_path).get_children():
		node.queue_free()
	pass

#Use the text retrieved from _start_recall to retrieve thoughts and thought properties
func process_thoughts(text_block):
	#Retrieve a union of the thought and "Transform" to recieve the transform numbers
	for i in text_block[0].split(")),"):
		var linked_node = i.split("',")[2].replace(" '","")
		print(linked_node)
	
#Instantiate a Thought Bubble node into the thought space
func load_thought(thought, transform):
	print (thought + " " + transform)

#Instantiate links between thoughts
func load_links():
	pass
	
func _create_new_thought(_value):
	if new_thought != "":
		print("Creating new thought: " + new_thought)
		var new_bubble = thought_scene.instance()
		new_bubble.set_name(new_thought)
		get_node(thoughtbubbles_path).add_child(new_bubble)
		new_bubble.set_owner(self)
		
		
