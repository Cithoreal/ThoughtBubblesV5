extends Spatial

var link_scene = load("res://Scenes/LineRenderer.tscn")

var bubble_node
var bubble_interface_node 
var parent_space_node 
var parent_bubble_node

func _enter_tree():
	bubble_node = get_parent()
	bubble_interface_node = get_parent().get_parent()
	parent_space_node = get_parent().get_parent().get_parent()
	parent_bubble_node = get_parent().get_parent().get_parent().get_parent()
	
	#Check if bubble is in a "Space" and not under the top "Scene" node
	if (parent_space_node.get_name() != get_viewport().get_child(0).get_name()):
		#Connect to signals in parent Space
		parent_space_node.connect("load_links", self, "load_link_nodes")

func new_linked_thought(new_thought):
	if (bubble_node.child_thoughts.find(new_thought) == -1):
		if (parent_space_node.find_node(new_thought) == null):
			var thoughts = []
			for thought in bubble_node.parent_thoughts:
				thoughts.append(thought)
			thoughts.append(bubble_interface_node.get_name())
			print("Creating and linking " + new_thought)
			parent_space_node.create_and_link_new_thought(new_thought, thoughts, global_transform.origin)
		else:
			bubble_node.child_thoughts.append(new_thought)
			bubble_node.get_node("Loading").load_parent_links(new_thought)
			parent_space_node.get_node(new_thought).get_child(1).load_link_nodes()
		print("Link to " + str(parent_space_node.get_node(new_thought)))

#Runs on signal from thought space after all thoughts have been loaded into the scene
func load_link_nodes():
	#clear existing link renderers
	for link in bubble_interface_node.get_child(3).get_children():
		link.free()
	#print("Loading Links")
	var linked_nodes = process_links()
	if (len(linked_nodes)>0):
		for node in process_links():
			var new_link_node = link_scene.instance()
			bubble_interface_node.get_child(3).add_child(new_link_node)
			#print(str(self) + " " + str(len(parent_thoughts)-1))
			new_link_node.bubble1 = node
			new_link_node.bubble2 = bubble_interface_node
			new_link_node.set_owner(get_viewport().get_child(0))
			new_link_node.initialize()

func process_links():
	if (len(bubble_node.parent_thoughts) <= 1):
		#Just render link to the thought space owner
		return [parent_bubble_node]
	
	var ordered_thoughts = []
	# Don't know how to initiate lists of specified sizes in gdscript
	# and too lazy to look it up when I can just do this
	for i in range(1, len(bubble_node.parent_thoughts)):
		ordered_thoughts.append([])
	
	#How many of my parent thoughts does each thought share as child thoughts?
	#If a parent thought's child thoughts include 0 of my own parent thoughts
	#That means it is a direct parent of mine, and I wish to render a line to it
	for i in range(1, len(bubble_node.parent_thoughts)):
		var shared_count = 0
		var parent_thought_1 = parent_space_node.get_node(bubble_node.parent_thoughts[i])
		for n in range(1, len(bubble_node.parent_thoughts)):
			
				var parent_thought_2 = parent_space_node.get_node(bubble_node.parent_thoughts[n])
				if (parent_thought_1.get_name() != parent_thought_2.get_name() && parent_thought_1.get_child(1).child_thoughts.find(parent_thought_2.get_name()) != -1):
					shared_count += 1

					
		ordered_thoughts[shared_count].append(parent_thought_1.get_name())
	
	var output_thoughts = []
	for parent in ordered_thoughts[0]:
		output_thoughts.append(parent_space_node.get_node(parent))
	return output_thoughts

func clear_links():
	for link in bubble_interface_node.get_child(3).get_children():
		link.free()
