extends Node3D

## WindowEmbeddingInterface - Integrates window embedding into ThoughtBubbles
## Provides UI and controls for managing embedded windows

class_name WindowEmbeddingInterface

signal window_selected(window_id: int)
signal program_launched(program: String, file: String)

@export var window_embedding_scene: PackedScene
@export var default_programs: Dictionary = {
	"text": "kate",
	"code": "code",
	"image": "gwenview",
	"pdf": "okular",
	"video": "vlc",
	"terminal": "konsole"
}

var active_embedding: Node3D = null
var file_dialogs: Dictionary = {}

func _ready():
	# Load the window embedding scene if not set
	if window_embedding_scene == null:
		window_embedding_scene = load("res://Scenes/WindowEmbeddingThought.tscn")

func open_file_in_window(file_path: String, program: String = ""):
	"""
	Open a file in an external program and embed the window
	"""
	if not FileAccess.file_exists(file_path):
		push_error("File does not exist: %s" % file_path)
		return
	
	# Determine program if not specified
	if program == "":
		program = determine_program_for_file(file_path)
	
	# Create window embedding instance
	if active_embedding != null:
		active_embedding.queue_free()
	
	active_embedding = window_embedding_scene.instantiate()
	add_child(active_embedding)
	
	# Configure the embedding
	active_embedding.target_program = program
	active_embedding.target_file_path = file_path
	active_embedding.auto_launch = true
	
	program_launched.emit(program, file_path)
	print_debug("Opening file %s with %s" % [file_path, program])

func embed_existing_window(window_id: int):
	"""
	Embed an existing window by its ID
	"""
	if active_embedding != null:
		active_embedding.queue_free()
	
	active_embedding = window_embedding_scene.instantiate()
	add_child(active_embedding)
	
	# Configure to capture existing window
	active_embedding.target_window_id = window_id
	active_embedding.auto_launch = false
	active_embedding.start_window_capture()
	
	window_selected.emit(window_id)
	print_debug("Embedding existing window ID: %d" % window_id)

func embed_window_by_title(title: String):
	"""
	Find and embed a window by its title
	"""
	if active_embedding != null:
		active_embedding.queue_free()
	
	active_embedding = window_embedding_scene.instantiate()
	add_child(active_embedding)
	
	# Configure to find window by title
	active_embedding.target_window_title = title
	active_embedding.auto_launch = false
	active_embedding.start_window_capture()
	
	print_debug("Embedding window with title: %s" % title)

func launch_program(program: String, args: Array = []):
	"""
	Launch a program and embed its window
	"""
	if active_embedding != null:
		active_embedding.queue_free()
	
	active_embedding = window_embedding_scene.instantiate()
	add_child(active_embedding)
	
	# Configure the embedding
	active_embedding.target_program = program
	active_embedding.auto_launch = true
	
	# Set file path if provided in args
	if args.size() > 0:
		active_embedding.target_file_path = args[0]
	
	program_launched.emit(program, args[0] if args.size() > 0 else "")
	print_debug("Launching program: %s" % program)

func determine_program_for_file(file_path: String) -> String:
	"""
	Determine the best program to open a file based on its extension
	"""
	var extension = file_path.get_extension().to_lower()
	
	match extension:
		"txt", "md", "rst":
			return default_programs.get("text", "kate")
		"gd", "cs", "py", "js", "cpp", "h", "json", "xml", "html", "css":
			return default_programs.get("code", "kate")
		"png", "jpg", "jpeg", "gif", "bmp", "webp":
			return default_programs.get("image", "gwenview")
		"pdf":
			return default_programs.get("pdf", "okular")
		"mp4", "mkv", "avi", "webm", "ogv":
			return default_programs.get("video", "vlc")
		_:
			# Default to text editor
			return default_programs.get("text", "kate")

func show_window_picker():
	"""
	Show a UI to select from available windows
	Returns array of available windows
	"""
	if active_embedding == null:
		var temp_embedding = window_embedding_scene.instantiate()
		add_child(temp_embedding)
		var windows = temp_embedding.list_available_windows()
		temp_embedding.queue_free()
		return windows
	else:
		return active_embedding.list_available_windows()

func close_embedded_window():
	"""
	Close the currently embedded window
	"""
	if active_embedding != null:
		active_embedding.close_window()
		active_embedding.queue_free()
		active_embedding = null

func get_embedded_window_texture() -> Texture2D:
	"""
	Get the texture of the currently embedded window
	"""
	if active_embedding != null:
		return active_embedding.get_window_texture()
	return null

func is_window_embedded() -> bool:
	"""
	Check if a window is currently embedded
	"""
	return active_embedding != null and active_embedding.is_capturing
