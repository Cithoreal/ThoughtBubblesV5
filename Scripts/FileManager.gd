@tool
extends Node

class_name FileManager

var FILE_PATH = "res://Files/"

# No need to extend, just use FileManager and save to ndjson and jsonld
# Saving to an incremental log, individual thought files, and potentially 
# a thought_dictionary which keeps link reference to all existing thoughts



#Save(savedata) Saves data to file
#Save_all()         Generic Save all
#Load()         loads file into cache
#Get(args[])    Get subset from cache


@export var FILE_NAME = "thought_dictionary"
var FILE_SUFFIX = ".json"

func save(data):
	print("Saving data to JSON")
	print(data)
	var file_path = FILE_PATH + FILE_NAME + FILE_SUFFIX
	print(file_path)
	var json_string = JSON.stringify(data)
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(json_string)
	file.close()
	#save_file(json_string, FILE_PATH + FILE_NAME + FILE_SUFFIX)
	
func save_jsonld(data_dict): # for thoughtbubbles #just get and update existing files with new timestamp
	print(data_dict)
	var file_path = FILE_PATH + data_dict["@id"] + ".jsonld"
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
