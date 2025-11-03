@tool
extends Node

class_name FileManager

const FILE_PATH = "res://Files/Thoughts/"

# No need to extend, just use FileManager and save to ndjson and jsonld
# Saving to an incremental log, individual thought files, and potentially 
# a thought_dictionary which keeps link reference to all existing thoughts



#Save(savedata) Saves data to file
#Save_all()         Generic Save all
#Load()         loads file into cache
#Get(args[])    Get subset from cache

	
func append_unique(array1: Array, array2: Array):
	for element in array2:
		if !array1.has(element):
			array1.append(element)
	return array1

func save_jsonld(data_dict): # for thoughtbubbles #just get and update existing files with new timestamp
	print_debug(data_dict)
	if not DirAccess.dir_exists_absolute(FILE_PATH):
		DirAccess.make_dir_absolute(FILE_PATH)
	var file_path = FILE_PATH + data_dict["@id"] + ".jsonld"
	print_debug("FILEPATH ", FILE_PATH)
	var file_exists = FileAccess.file_exists(file_path)
	var json_string :String

	if file_exists:
		var file = FileAccess.open(file_path, FileAccess.READ)
		var file_contents = file.get_as_text()
		file.close()

		var json = JSON.new()
		var err = json.parse(file_contents)
		if (err != OK):
			push_warning("JSON parse failed in %s: %s" % [file_path, json.get_error_message()])
			#Start file fresh, can log corrupted file to try to save any data (and look for last stable version)
			file = FileAccess.open(file_path, FileAccess.WRITE)

			data_dict["createdAt"] = data_dict["lastUpdated"]
			json_string = JSON.stringify(data_dict, "\t")
		else:
			var obj = json.get_data()
			obj["lastUpdated"] = data_dict["lastUpdated"]
			obj["LinkTo"] = append_unique(obj["LinkTo"], data_dict["LinkTo"])
			obj["LinkFrom"] = append_unique(obj["LinkFrom"], data_dict["LinkFrom"])
			json_string = JSON.stringify(obj, "\t")
	else:
		data_dict["createdAt"] = data_dict["lastUpdated"]
		json_string = JSON.stringify(data_dict, "\t")

	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(json_string)
	file.close()

func save_ndjson(): # for metadata and log
	pass
func save_all():
	print_debug("Saving all data to JSON")

func load_cache():
	print_debug("Loading cache from JSON")

func get_nodes(args):
	print_debug("Getting nodes from JSON")
	print_debug(args)

func array_to_dict(array):
	var out_dict = {}
	for element in array:
		out_dict[element] = []
	for i in range(0,len(array)):
		for n in range(i +1, len(array)):
			var arr = out_dict[array[i]]
			out_dict[array[i]].append(array[n])
	return out_dict

func load_jsonld(load_target: String):
	var file_path = FILE_PATH  + load_target + ".jsonld"
	#print_debug("loading from file Path:" + file_path)

	var obj = open_json_file(file_path)
	#print_debug("\n")
	#print_debug(obj["LinkTo"])
	return obj

func get_latest_timestamp(thought_id: String):
	var file_path = FILE_PATH + thought_id + ".jsonld"
	print_debug("loading from file Path: " + file_path)
	print_debug(open_json_file(file_path))
	return open_json_file(file_path)["lastUpdated"]

func open_json_file(file_path):
	if not FileAccess.file_exists(file_path):
		push_warning("No file at location: ", file_path)
		return "No File"
	var file = FileAccess.open(file_path, FileAccess.READ)
	var file_contents = file.get_as_text()
	file.close()

	var json = JSON.new()
	var err = json.parse(file_contents)
	if (err != OK):
		push_warning("JSON parse failed in %s: %s" % [file_path, json.get_error_message()])
		return "Invalid JSON"
	else:
		var obj = json.get_data()
		return obj
