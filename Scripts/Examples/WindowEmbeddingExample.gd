extends Node3D

## WindowEmbeddingExample - Demonstrates how to use window embedding in ThoughtBubbles
## This script shows various ways to embed windows into thought bubbles

# Example 1: Open a file in a window
func example_open_file():
	var window_interface = WindowEmbeddingInterface.new()
	add_child(window_interface)
	
	# Open a text file in Kate editor
	window_interface.open_file_in_window("/path/to/document.txt")
	
	# Open an image in Gwenview
	window_interface.open_file_in_window("/path/to/image.png", "gwenview")
	
	# Open a PDF in Okular
	window_interface.open_file_in_window("/path/to/document.pdf", "okular")

# Example 2: Embed an existing window by title
func example_embed_by_title():
	var window_interface = WindowEmbeddingInterface.new()
	add_child(window_interface)
	
	# Find and embed Firefox browser window
	window_interface.embed_window_by_title("Firefox")
	
	# Find and embed Kate editor
	window_interface.embed_window_by_title("Kate")

# Example 3: Launch a program and embed it
func example_launch_program():
	var window_interface = WindowEmbeddingInterface.new()
	add_child(window_interface)
	
	# Launch Konsole terminal
	window_interface.launch_program("konsole")
	
	# Launch Kate with a file
	window_interface.launch_program("kate", ["document.txt"])

# Example 4: Create a window thought in a space
func example_create_window_thought():
	# Get the space node (assuming it's a child of the thought bubble)
	var space_node = get_node("ThoughtBubbleInterface/Space")
	
	# Create a window thought for a file
	var window_thought = WindowThoughtExtension.create_window_thought(
		space_node,
		"MyDocument",
		"/path/to/document.txt",
		"kate"
	)
	
	print("Created window thought: ", window_thought.name)

# Example 5: List available windows
func example_list_windows():
	var window_interface = WindowEmbeddingInterface.new()
	add_child(window_interface)
	
	var windows = window_interface.show_window_picker()
	
	print("Available windows:")
	for window_info in windows:
		print("  - ID: %d, Title: %s" % [window_info.window_id, window_info.title])
	
	# Embed the first window
	if windows.size() > 0:
		window_interface.embed_existing_window(windows[0].window_id)

# Example 6: Check if running on Wayland
func example_check_wayland():
	var wayland_capture = WaylandWindowCapture.new()
	
	if wayland_capture.is_wayland_session():
		print("Running on Wayland session")
	else:
		print("Not running on Wayland - window capture may not work")
	
	if wayland_capture.is_kwin_available():
		print("KWin is available")
	else:
		print("KWin not available - window capture will not work")
	
	wayland_capture.queue_free()

# Example 7: Handle window events
func example_window_events():
	var window_interface = WindowEmbeddingInterface.new()
	add_child(window_interface)
	
	# Connect to signals
	window_interface.window_selected.connect(_on_window_selected)
	window_interface.program_launched.connect(_on_program_launched)
	
	# Open a file
	window_interface.open_file_in_window("/path/to/document.txt")

func _on_window_selected(window_id: int):
	print("Window selected: ", window_id)

func _on_program_launched(program: String, file: String):
	print("Program launched: %s with file: %s" % [program, file])

# Example 8: Smart file type detection
func example_smart_file_creation():
	var space_node = get_node("ThoughtBubbleInterface/Space")
	
	# Automatically detect file type and create appropriate thought
	var files = [
		"/path/to/document.txt",
		"/path/to/image.png",
		"/path/to/video.mp4",
		"/path/to/code.gd"
	]
	
	for file_path in files:
		var thought_type = WindowThoughtExtension.get_file_type_for_thought(file_path)
		print("File: %s -> Type: %s" % [file_path, thought_type])
		
		if thought_type == "window_embedding":
			WindowThoughtExtension.create_window_thought(space_node, file_path.get_file(), file_path)

# Example 9: Configure default programs
func example_configure_programs():
	var window_interface = WindowEmbeddingInterface.new()
	add_child(window_interface)
	
	# Override default programs
	window_interface.default_programs["text"] = "gedit"
	window_interface.default_programs["code"] = "vscode"
	window_interface.default_programs["pdf"] = "evince"
	
	# Now files will open with the new defaults
	window_interface.open_file_in_window("document.txt")  # Opens in gedit

# Example 10: Close embedded window
func example_close_window():
	var window_interface = WindowEmbeddingInterface.new()
	add_child(window_interface)
	
	# Open a window
	window_interface.open_file_in_window("/path/to/document.txt")
	
	# Wait a bit...
	await get_tree().create_timer(5.0).timeout
	
	# Close the window
	window_interface.close_embedded_window()

# Run all examples (comment out as needed)
func _ready():
	print("=== Window Embedding Examples ===")
	print("Uncomment the examples you want to run")
	
	# example_check_wayland()
	# example_list_windows()
	# example_open_file()
	# example_embed_by_title()
	# example_launch_program()
	# example_create_window_thought()
	# example_window_events()
	# example_smart_file_creation()
	# example_configure_programs()
	# example_close_window()
