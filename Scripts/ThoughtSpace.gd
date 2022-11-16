tool
extends Spatial

export(bool) var load_collection setget _start_recall
export(bool) var save_thoughts setget _save
export var recall_thought = ""
var MB_to_godot_path = "/run/media/cithoreal/Elements/MemoryBase/ToThoughts-Git/MB_to_godot.py"
var godot_to_nodes_path = "/run/media/cithoreal/Elements/MemoryBase/ToThoughts-Git/godot_to_nodes.py"

var links_path = "Links"
var thoughtbubbles_path = "----Thought Bubbles----"

func _start_recall(_value):
	if (recall_thought != ""):
		var output = []
		OS.execute(MB_to_godot_path, [recall_thought], true, output)
		process_thoughts(output)

func _save(_value):
	if (recall_thought != ""):
		print("saving thoughts")
		OS.execute(godot_to_nodes_path, [], false)

func clear_scene():
	for link in get_node(links_path).get_children():
		link.queue_free()
	for node in get_node(thoughtbubbles_path).get_children():
		node.queue_free()
	pass
	#find all LineRender and ThoughtBubble scripts and remove nodes they are attached to 

func process_thoughts(text_block):
	#Retrieve a union of the thought and "Transform" to recieve the transform numbers
	for i in text_block[0].split(")),"):
		var linked_node = i.split("',")[2].replace(" '","")
		print(linked_node)
	

func load_thought(thought, transform):
	print (thought + " " + transform)
	
func load_links():
	pass
