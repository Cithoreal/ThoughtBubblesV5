@tool
extends Node


class_name ThoughtBubbleStore

# intermediate step between bubble and filemanager
# should abstract logic and make it feature rich

# thoughtbubbles should be expandable and collapsable in data
# all relevant properties can be expanded to their own thoughts and be used to link and reference all other thoughtbubbles that share them
# properties should also be able to be collapsed down into a jsonld file to limit the total number of thoughts and links

#thoughtbubbles can be stored in an ndjson file or in a jsonld graph, being able to collapse to one file is useful for networking
#thoughtbubbles can also be expanded out to individual jsonld files that all link to each other, this is useful for interchangability
# and atomic work

# to start with, I will work on the fully expanded approach and an ndjson log
# can also automatically commit changes to a git repo for backup and version history

#each node neds an @context from an online or local semantic definition

# current space should contain an "address path" ordered context breadcrumb trail so when a thoughtbubble is updated, the whole context can recieve a 
#latest update timestamp

#a bubble looking to save a value should pass its own id and property to update and the whole context trail

#for some more arbitrary/artful ideas, specific categories of properties can be in their own files for my own sanity and ease of organization
# for example, a positions.ndjson, colors.ndjson, timestamps.ndjson, and bubbles.ndjson, 
# or thoughtbubbles themselves can exist as individual files with properties/metadata condensed into their own files

#recieve data dictionary, break it down and categorize known properties/metadata

#clear out links to positions and values that are commited to a git memory to keep current graphs lean
var file_manager: FileManager
var sets

func _enter_tree():
	file_manager = get_child(0)
	sets = get_child(1)


func save_dict_template(id: String, data: String, timestamp: String, forwardLinks: Array, backLinks: Array):
	forwardLinks.pop_front()
	var save_dict = {
 		"@id": id,
 		"@context": "/home/cithoreal/ThoughtBubbles/vocab/tb#",
 		"data": data, # text or link
 		"lastUpdated": timestamp,
 		"LinkTo": forwardLinks.map(func(element): return element["id"]),
		"LinkFrom": backLinks.map(func(element): return element["id"])

 	}
	return save_dict
	
func save(timestamp: String, save_array: Array[Dictionary]):
	print_debug(save_array)
	for i in range(save_array.size()):
		var forwardLinks : Array = save_array.slice(i,save_array.size())
		var backLinks : Array = save_array.slice(0,i)
		backLinks.reverse()
		var save_dict = save_dict_template(save_array[i]["id"], save_array[i]["data"], timestamp, forwardLinks, backLinks)
		file_manager.save_jsonld(save_dict)
		if save_array[i].has("tags"):
			var tags: Array = save_array[i]["tags"]
			save_array[i].erase("tags")
			for tag in tags:
				save(timestamp, [{"id":tag, "data":tag},save_array[i]])

func get_thought_data(thought_id: String):
	var data = file_manager.load_jsonld(thought_id)
	if typeof(data) == 0 or typeof(data) == TYPE_STRING:
		return null
	print_debug(data)
	return data["data"]



#takes a thought id, a value,  and a parent tag label list
#gets tags of the thought id in its "LinkFrom" set
# for example, when getting tags of the value -6.0 on puck
# get the puck backlinks, intersect with timestamp and tags, then remove any remaining that don't contain the value
func get_tags(timestamp: String, thought_id: String, value: String, tags: Array):
	print_debug("Getting tags for ", thought_id, " ", value)
	var data_at_timestamp = file_manager.load_jsonld("Timestamp-[%s]" % timestamp)["LinkTo"]
	var thought_backlinks = file_manager.load_jsonld(thought_id)["LinkFrom"]
	var out_set = sets.IntersectArrays(data_at_timestamp, thought_backlinks)
	for tag in tags:
		out_set = sets.IntersectArrays(out_set, file_manager.load_jsonld(tag)["LinkTo"])
	var return_set: Array
	for element in out_set:
		if file_manager.load_jsonld(element)["LinkTo"].has(value):
			return_set.append(element)
	return return_set

func get_values(timestamp: String, thought_id: String, property: String, value: String):
	print_debug("Getting values for ", thought_id, " ", property)
	var data_at_timestamp = file_manager.load_jsonld("Timestamp-[%s]" % timestamp)["LinkTo"]
	var thought_backlinks = file_manager.load_jsonld(thought_id)["LinkFrom"] 
	var out_set = sets.IntersectArrays(data_at_timestamp, thought_backlinks) #These three lines get the set of backlinks at the timestamp

	out_set = sets.IntersectArrays(out_set, file_manager.load_jsonld(property)["LinkTo"])
	out_set = sets.IntersectArrays(out_set, file_manager.load_jsonld(value)["LinkTo"])
	return out_set
	




func load_thoughts(load_array: Array):
	#print_debug(load_array)
	var data_output = file_manager.load_jsonld(load_array[0])["LinkTo"]
	#print_debug(data_output)
	for property in load_array:
		var out = file_manager.load_jsonld(property)
		data_output = sets.IntersectArrays(data_output, out["LinkTo"])
	#print_debug(data_output)
	#print_debug(get_thought_data(data_output[0]))
	return data_output


func load_thought(thought_id, timestamp, load_array):
	print_debug("LOAD DATA START: ", thought_id)
	print_debug(load_array)
	#print_debug(thought_id, timestamp, load_array)
	var data_at_timestamp = file_manager.load_jsonld("Timestamp-[%s]" % timestamp)
	var data_output:Array = data_at_timestamp["LinkTo"]


   # print_debug("tbs 162 - data_output", data_output)
	#print_debug("tbs 163 - out[linkTo[", data_output)
	for property in load_array:
		var out = file_manager.load_jsonld(property)
		#print_debug("property: ", property)
		#print_debug("intersect1: ", data_output)
		#print_debug("intersect2: ", out["LinkTo"])

		data_output = sets.IntersectArrays(data_output, out["LinkTo"])
	
	data_output = sets.IntersectArrays(data_output, file_manager.load_jsonld(thought_id)["LinkFrom"])
	
	print_debug("data output: ", data_output)

	if len(data_output) > 1:
		print_debug("Multiple results found, exclusion step")
		#data_output = sets.ExcludeArray(data_output, thought_id)
		# get all associated properties of values within the context of thought id backlinks
		#probably want to keep whole data objects when loading them, compared based on links as done so I can just use them for this step

		#Need to exclude any properties associated with child thoughts
		var property_array = []
		for value in data_output:
			var tags = get_tags(timestamp, thought_id, value, ["property", "atomic-property"])
			property_array.append_array(tags)
		property_array = sets.RemoveDuplicates(property_array)
		for property in load_array:
			if property_array.has(property):
				property_array.erase(property)
		
		print_debug("excluded properties for ",thought_id, ": ", property_array)
		for property in property_array:
			var values = get_values(timestamp, thought_id, property, "value")
			print_debug("values to exclude: ", values)
			if len(values) > 1:
				data_output = sets.ExcludeArray(data_output, values)

	print_debug("Final Data Output: ",data_output)
				


	if data_output.has(thought_id):
		data_output.remove_at(data_output.find(thought_id))
	#if len(data_output)>0:
	   # load_thought(thought_id, timestamp, data_output)
	print_debug("LOAD DATA END")
	return data_output[0]



func get_latest_timestamp(thought_id: String):
	return file_manager.get_latest_timestamp(thought_id)

#region load_properties

func get_bubble_property(thought_id, timestamp, property_array): # TODO Rewrite this to not reference specific loading procedures
	var output = []
	var load_array = [] # , loaded_nodes["`"+property+"`"], loaded_nodes["`"+element+"`"], loaded_nodes["`Timestamp`"]]
	load_array.append_array(property_array)
	#load_array.append("Timestamp")
	output = load_thought(thought_id, timestamp, load_array)
	print_debug(output)
	return output
	#var back_timestamps = thoughtbubble_store.get_from_orbitdb([timestamp], "`BackLink`")
	#print_debug(back_timestamps)

	if (!output.has(timestamp)):
		#Ensure this is the closest timestamp to the selected as possible
		for time in output:
			if (float(time) < float(timestamp)):
				timestamp = time
	#print_debug(output)		
	#print_debug(timestamp)	
	if (output.find(timestamp) > -1):
		load_array.pop_back()
		load_array.append(str(timestamp))
		#load_array = [loaded_nodes[bubble_interface_node.get_name()], loaded_nodes["`" + property + "`"], loaded_nodes["`" + element + "`"], loaded_nodes[str(timestamp)]]
		#print_debug(load_array)
	   # output = thoughtbubble_store.get_from_orbitdb(load_array)
		if (output.has(str(timestamp))):
			output.remove_at(output.find(str(timestamp)))
		if (len(output) > 0):
			return output
		else:
			return null
	else:
		print_debug("Remember to set the timestamp")
		#bubble_interface_node.visible = false


func load_position_x(thought_id, timestamp):
	timestamp = str(timestamp)
	var x = ""
	x = get_bubble_property(thought_id, timestamp, ["x-pos"])
	print_debug("X: ",x)
	return x

func load_position_y(thought_id, timestamp):
	timestamp = str(timestamp)
	var y = ""
	y = get_bubble_property(thought_id, timestamp, ["y-pos"])
	print_debug("Y: ",y)
	return y

func load_position_z(thought_id, timestamp):
	timestamp = str(timestamp)
	var z = ""
	z = get_bubble_property(thought_id, timestamp, ["z-pos"])
	print_debug("Z: ",z)
	return z
	
func load_color(thought_id, timestamp):
	var r = ""
	var g = ""
	var b = ""
	var a = ""

	r = get_bubble_property(thought_id, timestamp, ["`Color`", "`r`"])
	g = get_bubble_property(thought_id, timestamp, ["`Color`", "`g`"])
	b = get_bubble_property(thought_id, timestamp, ["`Color`", "`b`"])
	a = get_bubble_property(thought_id, timestamp, ["`Color`", "`a`"])
	r = r[len(r) - 1]
	g = g[len(g) - 1]
	b = b[len(b) - 1]
	a = a[len(a) - 1]
	if (r == "" || g == "" || b == "" || a == ""):
		return Color(0.329412, 0.517647, 0.6, 0.533333)

	else:
		r = float(r)
		g = float(g)
		b = float(b)
		a = float(a)
		return Color(r, g, b, a)



func load_shape(thought_id, timestamp):
	timestamp = str(timestamp)
	var shape = get_bubble_property(thought_id, timestamp, ["`Shape`"])
	shape = shape[len(shape) - 1]
	var shape_id = 0
	match shape:
		"CSGSphere3D":
			shape_id = 0
		"CSGBox3D":
			shape_id = 1
		"CSGCylinder3D":
			shape_id = 2
	return shape_id
	
	




#endregion
