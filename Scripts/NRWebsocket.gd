@tool
extends FileManager

class_name Neo4j
@export var save_test: bool : set = save
var socket = null
func _ready():
	socket = get_child(0)

func save(save_data):
	var json = JSON.stringify(save_data)
	socket.send_text(json)
	

	
func save_all():
	pass
	
func load_cache():
	pass
	
func get_nodes(args):
	pass

func _on_web_socket_server_text_received(peer: WebSocketPeer, id: int, message: String) -> void:
	print(message)
