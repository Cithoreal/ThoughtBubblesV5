@tool
extends Node3D

## WindowEmbedding - Captures and embeds external application windows into thought bubbles
## Targets Arch Linux with KDE Plasma Wayland compositor
## Streams window content to a SubViewport render texture for 3D display

signal window_captured(window_id: int)
signal window_lost(window_id: int)
signal window_frame_updated()

# Window properties
@export var target_window_id: int = -1
@export var target_window_title: String = ""
@export var target_program: String = ""
@export var target_file_path: String = ""
@export var auto_launch: bool = true
@export var capture_resolution: Vector2i = Vector2i(1920, 1080)
@export var capture_fps: float = 30.0

# Capture state
var is_capturing: bool = false
var window_process_id: int = -1
var wayland_capture: WaylandWindowCapture
var viewport_texture: ViewportTexture
var display_texture: ImageTexture
var subviewport: SubViewport

func _ready():
	if Engine.is_editor_hint():
		return
	
	setup_wayland_capture()
	setup_viewport()
	
	if auto_launch and target_program != "":
		launch_application()

func setup_wayland_capture():
	"""Setup Wayland window capture interface"""
	wayland_capture = WaylandWindowCapture.new()
	add_child(wayland_capture)
	wayland_capture.capture_frame_ready.connect(_on_capture_frame_ready)
	wayland_capture.capture_started.connect(_on_capture_started)
	wayland_capture.capture_stopped.connect(_on_capture_stopped)
	
	# Check if we're on Wayland
	if not wayland_capture.is_wayland_session():
		push_warning("Not running on Wayland - window capture may not work properly")
	
	if not wayland_capture.is_kwin_available():
		push_warning("KWin not available - window capture will not work")

func setup_viewport():
	"""Setup SubViewport for rendering captured window content"""
	subviewport = get_node_or_null("../SubViewport")
	if subviewport:
		viewport_texture = subviewport.get_texture()
		display_texture = ImageTexture.new()

func launch_application():
	"""Launch external application and capture its window"""
	if target_program == "":
		push_error("No target program specified")
		return
	
	var args = []
	if target_file_path != "":
		args.append(target_file_path)
	
	# Launch the application
	var pid = OS.create_process(target_program, args)
	if pid > 0:
		window_process_id = pid
		print_debug("Launched %s with PID %d" % [target_program, pid])
		
		# Wait a moment for window to appear, then start capturing
		await get_tree().create_timer(0.5).timeout
		start_window_capture()
	else:
		push_error("Failed to launch application: %s" % target_program)

func start_window_capture():
	"""Begin capturing window content"""
	if is_capturing:
		return
	
	# Find window by process ID or title
	if target_window_id == -1:
		target_window_id = find_window_by_process_or_title()
	
	if target_window_id != -1:
		is_capturing = true
		wayland_capture.start_continuous_capture(target_window_id, capture_fps)
		window_captured.emit(target_window_id)
		print_debug("Started capturing window ID: %d" % target_window_id)
	else:
		push_warning("Could not find window to capture")

func stop_window_capture():
	"""Stop capturing window content"""
	if not is_capturing:
		return
	
	is_capturing = false
	wayland_capture.stop_continuous_capture()
	print_debug("Stopped capturing window")

func find_window_by_process_or_title() -> int:
	"""
	Find window ID using KWin scripting or qdbus
	Returns window ID or -1 if not found
	"""
	if window_process_id > 0:
		# Try to find by process ID
		var window_info = wayland_capture.find_window_by_pid(window_process_id)
		if window_info != null:
			return window_info.window_id
	
	if target_window_title != "":
		# Try to find by title
		var window_info = wayland_capture.find_window_by_title(target_window_title)
		if window_info != null:
			return window_info.window_id
	
	return -1

func _on_capture_frame_ready(image: Image):
	"""Handle new frame from window capture"""
	if image == null or subviewport == null:
		return
	
	# Update the texture with the new frame
	display_texture.set_image(image)
	
	# Update the viewport with the captured content
	var texture_rect = subviewport.get_node_or_null("TextureRect")
	if texture_rect == null:
		# Create TextureRect if it doesn't exist
		texture_rect = TextureRect.new()
		texture_rect.name = "TextureRect"
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		subviewport.add_child(texture_rect)
	
	texture_rect.texture = display_texture
	window_frame_updated.emit()

func _on_capture_started(window_id: int):
	"""Handle capture started event"""
	print_debug("Window capture started for window %d" % window_id)

func _on_capture_stopped():
	"""Handle capture stopped event"""
	print_debug("Window capture stopped")

func get_window_texture() -> Texture2D:
	"""Get the current window capture as a texture"""
	if viewport_texture:
		return viewport_texture
	return null

func set_target_window(window_id: int):
	"""Set the window to capture by ID"""
	if target_window_id != window_id:
		stop_window_capture()
		target_window_id = window_id
		if window_id != -1:
			start_window_capture()

func close_window():
	"""Close the captured window and stop capture"""
	stop_window_capture()
	
	if window_process_id > 0:
		# Try to gracefully close the window
		OS.execute("kill", [str(window_process_id)], [], false, false)
		window_process_id = -1

func list_available_windows() -> Array:
	"""Get list of all available windows for selection"""
	if wayland_capture:
		return wayland_capture.list_windows()
	return []

func _exit_tree():
	"""Cleanup when node is removed"""
	stop_window_capture()
	if wayland_capture:
		wayland_capture.queue_free()
