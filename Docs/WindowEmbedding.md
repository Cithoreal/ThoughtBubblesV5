# Window Embedding Feature

## Overview

The Window Embedding feature allows ThoughtBubblesV5 to capture and display external application windows directly within thought bubbles in 3D space. This creates an immersive experience similar to Oculus and SteamVR's window pinning functionality.

## Target Platform

- **Primary Target**: Arch Linux with KDE Plasma Wayland
- **Compositor**: KWin (Wayland)
- **Window Protocol**: Wayland with KWin DBus interface

## Architecture

### Components

1. **WaylandWindowCapture.gd** - Low-level interface to KWin and Wayland
   - Queries window information via DBus
   - Captures window screenshots using KWin's screenshot API
   - Provides continuous capture at configurable FPS

2. **WindowEmbedding.gd** - Core window embedding logic
   - Manages window lifecycle (launch, capture, close)
   - Streams captured content to SubViewport
   - Handles window finding by PID or title

3. **WindowEmbeddingInterface.gd** - High-level API for thought bubbles
   - File type detection and program selection
   - Window picker and selection UI helpers
   - Integration with ThoughtBubbles data model

4. **WindowEmbeddingThought.tscn** - 3D scene for displaying windows
   - Uses SubViewport for rendering
   - Displays captured window content on a 3D plane
   - Similar structure to VideoThought.tscn

## Usage

### Opening a File in a Window

```gdscript
var window_interface = WindowEmbeddingInterface.new()
add_child(window_interface)

# Open a text file in Kate
window_interface.open_file_in_window("path/to/document.txt")

# Open with specific program
window_interface.open_file_in_window("path/to/image.png", "gwenview")
```

### Embedding an Existing Window

```gdscript
# Embed by window title
window_interface.embed_window_by_title("Firefox")

# Embed by window ID
var window_id = 12345
window_interface.embed_existing_window(window_id)
```

### Launching a Program

```gdscript
# Launch Kate text editor
window_interface.launch_program("kate")

# Launch with arguments
window_interface.launch_program("kate", ["document.txt"])
```

### Getting Available Windows

```gdscript
var windows = window_interface.show_window_picker()
for window_info in windows:
    print("Window: %s (ID: %d)" % [window_info.title, window_info.window_id])
```

## Technical Details

### Window Capture Method

The system uses KWin's DBus interface for window capture:

1. Query window list: `org.kde.KWin.getWindowInfo`
2. Capture screenshot: `org.kde.kwin.Screenshot.screenshotWindow`
3. Load captured image into Godot texture
4. Display in SubViewport for 3D rendering

### Performance Considerations

- **Capture Rate**: Default 30 FPS, configurable via `capture_fps` property
- **Resolution**: Default 1920x1080, configurable via `capture_resolution`
- **Resource Usage**: Window capture is CPU-intensive; limit active captures
- **Memory**: Each captured frame is stored as an Image in memory

### Limitations

1. **Wayland Security**: Some applications may block window capture
2. **Performance**: High capture rates can impact system performance
3. **KWin Dependency**: Requires KWin window manager (KDE Plasma)
4. **DBus Required**: System must have working DBus for KWin communication

## Default Programs by File Type

| File Type | Default Program |
|-----------|----------------|
| Text (.txt, .md) | kate |
| Code (.gd, .py, .js) | kate / code |
| Images (.png, .jpg) | gwenview |
| PDF (.pdf) | okular |
| Video (.mp4, .mkv) | vlc |

These can be customized in `WindowEmbeddingInterface.default_programs`.

## Integration with ThoughtBubbles

### Adding to Thought Bubbles

To integrate window embedding with the existing ThoughtBubble system:

1. **Add to Thought Types**: Update thought creation to support "window" type
2. **Save Window State**: Store window ID, program, and file path in JSON
3. **Restore on Load**: Re-launch programs and re-attach windows on load
4. **Link to Files**: Associate window embeddings with file thoughts

### Example Integration

```gdscript
# In thoughtbubble_interface.gd or similar
func create_window_thought(file_path: String):
    var thought_bubble = create_thought_bubble("Window_" + file_path.get_file())
    var window_interface = WindowEmbeddingInterface.new()
    thought_bubble.add_child(window_interface)
    window_interface.open_file_in_window(file_path)
    return thought_bubble
```

## Dependencies

### System Requirements

- **Operating System**: Arch Linux (primary), any Linux with KDE Plasma
- **Desktop Environment**: KDE Plasma 5.x or 6.x
- **Window Manager**: KWin (Wayland mode)
- **DBus**: System and session DBus
- **qdbus**: Command-line DBus tool (package: `qt6-tools` or `qt5-tools`)

### Optional Dependencies

- **PipeWire**: For advanced video streaming (future enhancement)
- **xdg-desktop-portal-kde**: For better Wayland integration
- **spectacle**: Alternative screenshot tool

## References

- [KWin DBus Interface Documentation](https://develop.kde.org/docs/plasma/kwin/)
- [Wayland Protocol Specifications](https://wayland.freedesktop.org/docs/html/)
- [Godot SubViewport Documentation](https://docs.godotengine.org/en/stable/classes/class_subviewport.html)
- [PipeWire Documentation](https://docs.pipewire.org/)
