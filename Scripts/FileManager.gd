tool
extends Node

var FILE_NAME = "res://Files/thought_dictionary.json"


func save(save_data):
	var file = File.new()
	file.open(FILE_NAME, File.READ_WRITE)
	var data = parse_json(file.get_as_text())
	if typeof(data) == TYPE_DICTIONARY:
		#if data.has(save_data[0]):
		print(data)
	file.store_string(file.get_as_text() + "\n" + to_json(save_data))
	file.close()
	
func load_file():
	var file = File.new()
	if file.file_exists(FILE_NAME):
		file.open(FILE_NAME, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			return data

		else:
			printerr("Corrupted data!")
	else:
		printerr("No saved data!")
