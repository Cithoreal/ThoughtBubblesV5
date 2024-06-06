@tool
extends FileManager

class_name JSONManager

@export var FILE_NAME = "thought_dictionary"
var FILE_SUFFIX = ".json"

func save_data(save_data):
	print("Saving data to JSON")
	print(save_data)
	var json_string = JSON.stringify(save_data)
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

