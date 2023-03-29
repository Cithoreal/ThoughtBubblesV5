@tool
extends Node

var FILE_PATH = "res://Files/thought_dictionary.json"
#Converting this file from Godot 3.5 to Godot 4.0
func save(save_data):
	
	
	if typeof(save_data) == TYPE_ARRAY:
		save_data = array_to_dict(save_data)
	#print(save_data)

	var file = FileAccess.open(FILE_PATH, FileAccess.READ_WRITE)
	var text = file.get_as_text()
	var test_json_conv = JSON.new()
	test_json_conv.parse(text)
	var data = test_json_conv.get_data()

	#print(data)
	if typeof(data) == TYPE_DICTIONARY:
		#print(save_data)
		#print (data)
		var merged_dict = data.duplicate()
		merged_dict.merge(save_data)
		for key in data:
			if save_data.has(key):
				for value in save_data[key]:
					if !merged_dict[key].has(str(value)):
						merged_dict[key].append(str(value))
		#print(data)
		#print(merged_dict)
		file.store_line(JSON.stringify(merged_dict))
	file.close()
	
func load_file():


	var file = FileAccess.open(FILE_PATH, FileAccess.READ)
	var text = file.get_as_text()
	var test_json_conv = JSON.new()
	test_json_conv.parse(text)
	var data = test_json_conv.get_data()

	file.close()
	if typeof(data) == TYPE_DICTIONARY:
		return data

	else:
		printerr("Corrupted data!")




func ensure_file_exists():

	if not FileAccess.file_exists(FILE_PATH):
		var file = FileAccess.open(FILE_PATH, FileAccess.WRITE)
		file.store_string(JSON.stringify({}))
		file.close()
		
#Takes an array and constructs a dictionary where every value becomes a key containing every value that follows
func array_to_dict(array):
	var out_dict = {}
	for element in array:
		out_dict[element] = []
	for i in range(0,len(array)):
		for n in range(i +1, len(array)):
			var arr = out_dict[array[i]]
			out_dict[array[i]].append(array[n])
	return out_dict
