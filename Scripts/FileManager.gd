tool
extends Node

var FILE_PATH = "res://Files/thought_dictionary.json"

func save(save_data):
	
	var file = File.new()
	if typeof(save_data) == TYPE_ARRAY:
		save_data = array_to_dict(save_data)
	#print(save_data)

	
	ensure_file_exists(FILE_PATH)

	file.open(FILE_PATH, File.READ_WRITE)
	var fixed_text = file.get_as_text()
	fixed_text = fixed_text.substr(0,fixed_text.find("}")+1)
	var data = parse_json(fixed_text)

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
		file.store_string(JSON.print(merged_dict))
	file.close()
	
func load_file():
	var file = File.new()
	ensure_file_exists(FILE_PATH)
	if file.file_exists(FILE_PATH):
		file.open(FILE_PATH, File.READ)
		var fixed_text = file.get_as_text()
		fixed_text = fixed_text.substr(0,fixed_text.find("}")+1)
		var data = parse_json(fixed_text)

		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			return data

		else:
			printerr("Corrupted data!")
	else:
		printerr("No saved data!")

func ensure_file_exists(file_path):
	var file = File.new()
	if !file.file_exists(file_path):
		file.open(file_path,File.WRITE)
		file.store_string(JSON.print({}))
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
