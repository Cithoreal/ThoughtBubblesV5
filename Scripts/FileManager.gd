@tool
extends Node

var FILE_PATH = "res://Files/thought_dictionary.json"
var ORBITDB_DIR = "C:/Users/cdica/Projects/IPFS-OrbitDB/Scripts/"
var SOCKET_SCRIPT = "DBSocket.js"

signal orbitdb_recieved(values)
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
	
func get_from_orbitdb(timestamp, thought):
	var thread = Thread.new()
	var callable = Callable(self, "_thread_get_orbitdb")
	callable = callable.bind(thought, timestamp)
	thread.start(callable, 1)

func _thread_get_orbitdb(thought, timestamp):
	var loadString = "node DBSocket.js get -1 "
	for value in thought:
		loadString = loadString + value + " "
	var output = []

	OS.execute("CMD.exe", ["/C", "cd C:/Users/cdica/Projects/IPFS-OrbitDB/Scripts/ && " + loadString], output)
	print(output)
	orbitdb_recieved.emit(output[0], timestamp)
#-1 means intersect return collection
#-2 means full dictionary collection
func save_to_orbitdb(thoughts):
	var thread = Thread.new()
	var callable = Callable(self, "_thread_save_to_orbitdb")
	callable = callable.bind(thoughts)
	thread.start(callable,1)
	
func _thread_save_to_orbitdb(node):
	var saveString = "node DBSocket.js post -1 "
	for value in node:
		saveString = saveString + value + " "
	var output = []
	#print(saveString)
	OS.execute("CMD.exe", ["/C", "cd C:/Users/cdica/Projects/IPFS-OrbitDB/Scripts/ && " + saveString], output)
	print(output)
	
#-1 means right directional full linking
#-2 means two directional full linking (All link to all)
#-3 means right directional linear linking
