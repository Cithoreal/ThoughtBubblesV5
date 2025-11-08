extends Node

## WindowThoughtExtension - Extension methods for creating window embedding thoughts
## This provides helpers to integrate window embedding with the ThoughtBubbles system

class_name WindowThoughtExtension

const WINDOW_THOUGHT_SCENE = "res://Scenes/WindowEmbeddingThought.tscn"

static func create_window_thought(parent_space: Node3D, thought_name: String, file_path: String = "", program: String = "") -> Node3D:
	"""
	Create a new window embedding thought in the given space
	
	Args:
		parent_space: The Space node to add the thought to
		thought_name: Name for the thought bubble
		file_path: Optional file path to open in the window
		program: Optional program to use (auto-detected if not provided)
	
	Returns:
		The created thought bubble node with window embedding
	"""
	var window_scene = load(WINDOW_THOUGHT_SCENE)
	if window_scene == null:
		push_error("Could not load WindowEmbeddingThought scene")
		return null
	
	var window_thought = window_scene.instantiate()
	window_thought.set_name(thought_name)
	
	# Configure window embedding
	if file_path != "":
		window_thought.target_file_path = file_path
	if program != "":
		window_thought.target_program = program
	
	# Add to parent space
	parent_space.add_child(window_thought)
	if parent_space.get_viewport() != null:
		window_thought.set_owner(parent_space.get_viewport().get_child(0))
	
	return window_thought

static func create_window_thought_from_bubble(thought_bubble: Node3D, file_path: String = "", program: String = ""):
	"""
	Add window embedding to an existing thought bubble
	
	Args:
		thought_bubble: Existing ThoughtBubble node
		file_path: Optional file path to open
		program: Optional program to use
	"""
	var window_interface = load("res://Scripts/WindowEmbeddingInterface.gd").new()
	thought_bubble.add_child(window_interface)
	
	if file_path != "":
		window_interface.open_file_in_window(file_path, program)
	
	return window_interface

static func save_window_thought_properties(thought_name: String, file_path: String, program: String, window_id: int, thoughtbubble_store) -> Dictionary:
	"""
	Create save data for a window embedding thought
	
	Returns:
		Dictionary with window thought properties
	"""
	return {
		"thought_type": "window_embedding",
		"file_path": file_path,
		"program": program,
		"window_id": window_id,
		"thought_name": thought_name
	}

static func load_window_thought_properties(thought_data: Dictionary, parent_space: Node3D) -> Node3D:
	"""
	Load a window embedding thought from saved data
	
	Args:
		thought_data: Dictionary containing window thought properties
		parent_space: Space node to add the thought to
	
	Returns:
		The loaded thought bubble with window embedding
	"""
	var thought_name = thought_data.get("thought_name", "")
	var file_path = thought_data.get("file_path", "")
	var program = thought_data.get("program", "")
	
	if thought_name == "":
		push_error("No thought name in window thought data")
		return null
	
	return create_window_thought(parent_space, thought_name, file_path, program)

static func get_file_type_for_thought(file_path: String) -> String:
	"""
	Determine thought type based on file extension
	Returns: "window_embedding", "image", "video", "3dmodel", or "text"
	"""
	var extension = file_path.get_extension().to_lower()
	
	# Check if it should be an embedded window
	var window_extensions = ["txt", "md", "gd", "cs", "py", "js", "json", "xml", "html", "pdf"]
	if extension in window_extensions:
		return "window_embedding"
	
	# Check for other thought types
	if extension in ["png", "jpg", "jpeg", "gif", "bmp", "webp"]:
		return "image"
	elif extension in ["mp4", "mkv", "avi", "webm", "ogv"]:
		return "video"
	elif extension in ["glb", "gltf", "obj", "fbx"]:
		return "3dmodel"
	else:
		return "text"

static func create_thought_for_file(parent_space: Node3D, file_path: String, thought_name: String = "") -> Node3D:
	"""
	Create the appropriate thought type for a file
	Automatically determines if it should be a window embedding or other type
	
	Args:
		parent_space: Space node to add the thought to
		file_path: Path to the file
		thought_name: Optional custom name (uses filename if not provided)
	
	Returns:
		The created thought bubble
	"""
	if thought_name == "":
		thought_name = file_path.get_file().get_basename()
	
	var thought_type = get_file_type_for_thought(file_path)
	
	if thought_type == "window_embedding":
		return create_window_thought(parent_space, thought_name, file_path)
	else:
		# Create standard thought and note the file association
		# This would be handled by existing thought creation logic
		push_warning("Non-window thought types not handled by WindowThoughtExtension")
		return null
