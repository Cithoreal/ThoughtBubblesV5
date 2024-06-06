@tool
extends Node

class_name FileManager

var FILE_PATH = "res://Files/"

#Save(savedata) Saves data to file
#Save_all()         Generic Save all
#Load()         loads file into cache
#Get(args[])    Get subset from cache


func save(save_data):
	pass
	
func save_all():
	pass
	
func load_cache():
	pass
	
func get_nodes(args):
	pass

func array_to_dict(array):
	var out_dict = {}
	for element in array:
		out_dict[element] = []
	for i in range(0,len(array)):
		for n in range(i +1, len(array)):
			var arr = out_dict[array[i]]
			out_dict[array[i]].append(array[n])
	return out_dict
