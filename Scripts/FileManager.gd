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

func save_data(data):
	print("Saving data to JSON")
	print(data)
	var json_string = JSON.stringify(data)
	var file = FileAccess.open(FILE_PATH + FILE_NAME + FILE_SUFFIX, FileAccess.WRITE)
	file.store_string(json_string)
	file.close()
	#save_file(json_string, FILE_PATH + FILE_NAME + FILE_SUFFIX)
	
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
