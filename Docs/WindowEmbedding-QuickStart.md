# Window Embedding - Quick Start Guide

## Prerequisites

Before using window embedding, ensure you have:

1. **Arch Linux** with KDE Plasma (Wayland session)
2. **KWin** compositor running
3. **DBus** installed and running
4. **qdbus** command-line tool: `sudo pacman -S qt6-tools`

## Quick Check

Run this in terminal to verify your setup:

```bash
# Check if you're on Wayland
echo $XDG_SESSION_TYPE  # Should output "wayland"

# Check if KWin is accessible
qdbus org.kde.KWin /KWin org.kde.KWin.getWindowInfo
```

## Basic Usage

### 1. Open a File in a Window

```gdscript
# In your scene script
var window_interface = WindowEmbeddingInterface.new()
add_child(window_interface)

# Open a text file in Kate
window_interface.open_file_in_window("/path/to/document.txt")
```

### 2. Embed an Existing Window

```gdscript
# Embed Firefox browser
window_interface.embed_window_by_title("Firefox")

# Or embed by window ID
window_interface.embed_existing_window(12345)
```

### 3. Launch a New Program

```gdscript
# Launch Konsole terminal
window_interface.launch_program("konsole")

# Launch Kate with a file
window_interface.launch_program("kate", ["/path/to/file.txt"])
```

## Adding to ThoughtBubbles

### Create a Window Thought

```gdscript
# Get your space node
var space_node = get_node("ThoughtBubbleInterface/Space")

# Create a window thought
var window_thought = WindowThoughtExtension.create_window_thought(
    space_node,
    "MyDocument",          # Thought name
    "/path/to/doc.txt",   # File to open
    "kate"                 # Program to use
)
```

### Auto-Detect File Type

```gdscript
# Automatically choose the right thought type
var thought = WindowThoughtExtension.create_thought_for_file(
    space_node,
    "/path/to/file.txt"  # Will open in window if it's a text/code file
)
```

## Default Programs

The system auto-selects programs based on file type:

| File Type | Program |
|-----------|---------|
| .txt, .md | kate |
| .gd, .py, .js | kate |
| .png, .jpg | gwenview |
| .pdf | okular |
| .mp4, .mkv | vlc |

### Customize Default Programs

```gdscript
var window_interface = WindowEmbeddingInterface.new()
add_child(window_interface)

# Change default text editor to gedit
window_interface.default_programs["text"] = "gedit"

# Change code editor to VS Code
window_interface.default_programs["code"] = "code"
```

## Common Issues

### "Window not found"
- Wait a moment after launching before capturing
- Try increasing delay: `await get_tree().create_timer(1.0).timeout`

### "KWin not available"
- Ensure you're running KDE Plasma with Wayland
- Check: `qdbus org.kde.KWin`

### Poor Performance
- Reduce capture FPS: `window_embedding.capture_fps = 15.0`
- Lower resolution: `window_embedding.capture_resolution = Vector2i(1280, 720)`

## Testing

Use the demo scene to test window embedding:

1. Open `Scenes/WindowEmbeddingDemo.tscn`
2. Run the scene
3. Test from the console or modify the demo script

## Next Steps

- Read full documentation: [Docs/WindowEmbedding.md](WindowEmbedding.md)
- See all examples: [Scripts/Examples/WindowEmbeddingExample.gd](../Scripts/Examples/WindowEmbeddingExample.gd)
- Integrate with your ThoughtBubbles workflow

## Support

For issues or questions:
1. Check the full documentation
2. Review the example scripts
3. Open an issue on GitHub

## Platform Notes

### Current Support
- ✅ Arch Linux + KDE Plasma Wayland
- ✅ KWin compositor

### Planned Support
- ⏳ Other Linux distros with KDE Plasma
- ⏳ GNOME Wayland (Mutter compositor)
- ⏳ Generic Wayland compositors

### Not Supported
- ❌ X11 (use XWayland fallback)
- ❌ Windows
- ❌ macOS
