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

	
func save_jsonld(data_dict): # for thoughtbubbles #just get and update existing files with new timestamp
	print(data_dict)
	if not DirAccess.dir_exists_absolute(FILE_PATH):
		DirAccess.make_dir_absolute(FILE_PATH)
	var file_path = FILE_PATH + data_dict["@id"] + ".jsonld"
	print("FILEPATH ", FILE_PATH)
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
	print("Saving all data to JSON")

func load_cache():
	print("Loading cache from JSON")

func get_nodes(args):
	print("Getting nodes from JSON")
	print(args)

func array_to_dict(array):
	var out_dict = {}
	for element in array:
		out_dict[element] = []
	for i in range(0,len(array)):
		for n in range(i +1, len(array)):
			var arr = out_dict[array[i]]
			out_dict[array[i]].append(array[n])
	return out_dict

func load_jsonld(load_target):
	var file_path = FILE_PATH  + load_target + ".jsonld"
	print("loading from file Path:" + file_path)

	var obj = open_json_file(file_path)
	print("\n")
	print(obj["LinkTo"])
	return obj

func get_latest_timestamp(thought_id: String):
	var file_path = FILE_PATH + thought_id + ".jsonld"
	print("loading from file Path: " + file_path)
	print(open_json_file(file_path))
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

