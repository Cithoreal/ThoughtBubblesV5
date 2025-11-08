extends Node

## WaylandWindowCapture - Native GDScript interface for KDE Plasma Wayland window capture
## This provides the low-level interface to KWin and Wayland protocols

class_name WaylandWindowCapture

signal capture_frame_ready(texture: Image)
signal capture_started(window_id: int)
signal capture_stopped()
signal window_list_updated(windows: Array)

# Window information structure
class WindowInfo:
	var window_id: int
	var pid: int
	var title: String
	var geometry: Rect2i
	var is_active: bool
	
	func _init(id: int = -1, p: int = -1, t: String = "", g: Rect2i = Rect2i()):
		window_id = id
		pid = p
		title = t
		geometry = g
		is_active = false

# Capture state
var active_window_id: int = -1
var capture_active: bool = false
var capture_image: Image
var last_capture_time: float = 0.0

# KWin DBus interface constants
const KWIN_SERVICE = "org.kde.KWin"
const KWIN_PATH = "/KWin"
const KWIN_INTERFACE = "org.kde.KWin"
const SCREENSHOT_PATH = "/Screenshot"
const SCREENSHOT_INTERFACE = "org.kde.kwin.Screenshot"

func _init():
	capture_image = Image.create(1920, 1080, false, Image.FORMAT_RGBA8)

func list_windows() -> Array[WindowInfo]:
	"""
	Query KWin for list of all windows
	Returns array of WindowInfo objects
	"""
	var windows: Array[WindowInfo] = []
	
	# Execute qdbus to get window list
	var output = []
	var exit_code = OS.execute("qdbus", [
		KWIN_SERVICE,
		KWIN_PATH,
		KWIN_INTERFACE + ".getWindowInfo"
	], output, true, false)
	
	if exit_code == 0 and output.size() > 0:
		windows = parse_window_list(output[0])
	else:
		push_warning("Failed to query KWin for windows")
	
	return windows

func parse_window_list(window_data: String) -> Array[WindowInfo]:
	"""Parse window information from KWin output"""
	var windows: Array[WindowInfo] = []
	
	# KWin output parsing would go here
	# This is a simplified placeholder
	
	return windows

func find_window_by_title(title_pattern: String) -> WindowInfo:
	"""
	Find window by title (supports partial matching)
	Returns WindowInfo or null if not found
	"""
	var windows = list_windows()
	for window in windows:
		if title_pattern.to_lower() in window.title.to_lower():
			return window
	return null

func find_window_by_pid(process_id: int) -> WindowInfo:
	"""
	Find window by process ID
	Returns WindowInfo or null if not found
	"""
	var windows = list_windows()
	for window in windows:
		if window.pid == process_id:
			return window
	return null

func capture_window(window_id: int) -> Image:
	"""
	Capture a single frame from the specified window
	Uses KWin screenshot functionality
	"""
	var temp_file = "/tmp/thoughtbubbles_capture_%d.png" % Time.get_ticks_msec()
	
	# Use KWin screenshot DBus interface
	var output = []
	var exit_code = OS.execute("qdbus", [
		KWIN_SERVICE,
		SCREENSHOT_PATH,
		SCREENSHOT_INTERFACE + ".screenshotWindow",
		str(window_id),
		temp_file
	], output, true, false)
	
	if exit_code == 0:
		# Load the captured image
		var image = Image.new()
		var error = image.load(temp_file)
		
		if error == OK:
			# Clean up temp file
			DirAccess.remove_absolute(temp_file)
			return image
		else:
			push_error("Failed to load captured image: %d" % error)
	else:
		push_warning("Failed to capture window %d" % window_id)
	
	return null

func start_continuous_capture(window_id: int, fps: float = 30.0):
	"""
	Start continuously capturing window at specified FPS
	Note: This is resource intensive and should be used carefully
	"""
	if capture_active:
		stop_continuous_capture()
	
	active_window_id = window_id
	capture_active = true
	last_capture_time = 0.0
	
	capture_started.emit(window_id)

func stop_continuous_capture():
	"""Stop continuous window capture"""
	capture_active = false
	active_window_id = -1
	capture_stopped.emit()

func _process(delta: float):
	"""Process continuous capture if active"""
	if not capture_active or active_window_id == -1:
		return
	
	# Capture at specified rate (30 FPS = 0.033s)
	last_capture_time += delta
	if last_capture_time >= 0.033:
		last_capture_time = 0.0
		
		var image = capture_window(active_window_id)
		if image != null:
			capture_frame_ready.emit(image)

func get_active_window() -> WindowInfo:
	"""Get information about the currently active/focused window"""
	var output = []
	var exit_code = OS.execute("qdbus", [
		KWIN_SERVICE,
		KWIN_PATH,
		KWIN_INTERFACE + ".getActiveWindow"
	], output, true, false)
	
	if exit_code == 0 and output.size() > 0:
		# Parse active window info
		# This would need proper implementation
		pass
	
	return null

func activate_window(window_id: int) -> bool:
	"""
	Bring window to front and focus it
	Returns true if successful
	"""
	var output = []
	var exit_code = OS.execute("qdbus", [
		KWIN_SERVICE,
		KWIN_PATH,
		KWIN_INTERFACE + ".setActiveWindow",
		str(window_id)
	], output, true, false)
	
	return exit_code == 0

func get_window_geometry(window_id: int) -> Rect2i:
	"""Get the position and size of a window"""
	var output = []
	var exit_code = OS.execute("qdbus", [
		KWIN_SERVICE,
		KWIN_PATH,
		KWIN_INTERFACE + ".getWindowGeometry",
		str(window_id)
	], output, true, false)
	
	if exit_code == 0 and output.size() > 0:
		# Parse geometry from output
		# Format is typically: x,y,width,height
		return parse_geometry(output[0])
	
	return Rect2i()

func parse_geometry(geo_string: String) -> Rect2i:
	"""Parse geometry string to Rect2i"""
	var parts = geo_string.split(",")
	if parts.size() >= 4:
		return Rect2i(
			int(parts[0]),
			int(parts[1]),
			int(parts[2]),
			int(parts[3])
		)
	return Rect2i()

func is_wayland_session() -> bool:
	"""Check if running under Wayland"""
	var session_type = OS.get_environment("XDG_SESSION_TYPE")
	return session_type == "wayland"

func is_kwin_available() -> bool:
	"""Check if KWin is running and accessible"""
	var output = []
	var exit_code = OS.execute("qdbus", [
		KWIN_SERVICE,
		KWIN_PATH,
		KWIN_INTERFACE + ".getWindowInfo"
	], output, true, false)
	
	return exit_code == 0
