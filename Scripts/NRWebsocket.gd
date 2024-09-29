@tool
extends FileManager

class_name Neo4j
@export var save_test: bool : set = save
var socket = null


func save(save_data):
	socket = find_child("SaveThoughtsSocket")
	var json = JSON.stringify(save_data, "\t", false)
	print(json)
	#print(save_data)
	socket.send_text(json)
	

	
func save_all():
	pass
	
func load_cache():
	pass
	
func get_nodes(args):
	pass

func _on_web_socket_server_text_received(peer: WebSocketPeer, id: int, message: String) -> void:
	print(message)
