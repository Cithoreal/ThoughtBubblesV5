@tool
extends Node

var FILE_PATH = "res://Files/thought_dictionary.json"
var ORBITDB_DIR = "C:/Users/cdica/Projects/IPFS-OrbitDB/Scripts/"
var SOCKET_SCRIPT = "DBSocket.js"

func save(save_data):
	save_to_orbitdb(save_data)
	
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
	
func get_from_orbitdb(thoughts):

	var loadString = "node DBSocket.js get -1 "
	for value in thoughts:
		loadString = loadString + value + " "
	var output = []

	OS.execute("CMD.exe", ["/C", "cd C:/Users/cdica/Projects/IPFS-OrbitDB/Scripts/ && " + loadString], output)
	#print(output[0])

	var processed_output = output[0].replace("values: ", "")
	processed_output = processed_output.replace("\n", "")
	var arr= processed_output.split(',')
	#print(arr)
	return(arr)
	
	#Convert to dictionary before returning?
#-1 means intersect return collection
#-2 means full dictionary collection


func save_to_orbitdb(thoughts):
	var saveString = "node DBSocket.js post -1 "
	for value in thoughts:
		saveString = saveString + value + " "
	var output = []
	#print(saveString)
	OS.execute("CMD.exe", ["/C", "cd C:/Users/cdica/Projects/IPFS-OrbitDB/Scripts/ && " + saveString], output)
	print(output)
	

	
#-1 means right directional full linking
#-2 means two directional full linking (All link to all)
#-3 means right directional linear linking
