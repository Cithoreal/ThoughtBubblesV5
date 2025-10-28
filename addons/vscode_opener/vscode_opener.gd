@tool
extends EditorPlugin

const TOOL_MENU_ITEM := "Open Selected File in VSCode"
const PRIMARY_VSCODE_PATH := "/usr/local/bin/code"
const SECONDARY_VSCODE_PATH := "/opt/homebrew/bin/code"
const MACOS_CODE_CANDIDATES := [
    PRIMARY_VSCODE_PATH,
    SECONDARY_VSCODE_PATH,
    "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
]
const LINUX_CODE_CANDIDATES := [
    "/usr/bin/code",
    "/usr/local/bin/code",
    "/var/lib/snapd/snap/bin/code",
    "/snap/bin/code"
]
const WINDOWS_CODE_CANDIDATES := [
    "%LOCALAPPDATA%\\Programs\\Microsoft VS Code\\Code.exe",
    "%LOCALAPPDATA%\\Programs\\Microsoft VS Code\\bin\\code.cmd",
    "%ProgramFiles%\\Microsoft VS Code\\Code.exe",
    "%ProgramFiles%\\Microsoft VS Code\\bin\\code.cmd",
    "%ProgramFiles(x86)%\\Microsoft VS Code\\Code.exe",
    "%ProgramFiles(x86)%\\Microsoft VS Code\\bin\\code.cmd"
]

var _fs_dock: Control
var _fs_trees: Array = []

func _enter_tree():
    add_tool_menu_item(TOOL_MENU_ITEM, Callable(self, "_on_open_in_vscode"))
    call_deferred("_initialize_file_system_hooks")

func _exit_tree():
    remove_tool_menu_item(TOOL_MENU_ITEM)
    _disconnect_file_system_signals()
    _fs_dock = null
    _fs_trees.clear()

func _on_open_in_vscode():
    var editor := get_editor_interface()
    var path := _get_selected_resource_path(editor)
    if path.is_empty():
        push_warning("No file selected in FileSystem dock.")
        return
    _open_path_in_vscode(path)

func _initialize_file_system_hooks():
    _fs_dock = get_editor_interface().get_file_system_dock()
    if _fs_dock == null:
        call_deferred("_initialize_file_system_hooks")
        return

    _fs_trees = _find_all_trees(_fs_dock)

    _connect_file_system_signals()

func _get_selected_resource_path(editor: EditorInterface) -> String:
    var fs_dock := editor.get_file_system_dock()
    if fs_dock:
        if fs_dock.has_method("get_selected_files"):
            var selected = fs_dock.call("get_selected_files")
            if selected is Array and selected.size() > 0:
                return str(selected[0])
            if selected is PackedStringArray and selected.size() > 0:
                return selected[0]
        if fs_dock.has_method("get_selected_paths"):
            var selected_paths = fs_dock.call("get_selected_paths")
            if selected_paths is Array and selected_paths.size() > 0:
                return str(selected_paths[0])
            if selected_paths is PackedStringArray and selected_paths.size() > 0:
                return selected_paths[0]

    return editor.get_current_path()

func _resolve_vscode_path() -> String:
    var detected := _find_code_in_path()
    if not detected.is_empty():
        return detected

    match OS.get_name():
        "macOS":
            var mac_path := _first_existing_path(MACOS_CODE_CANDIDATES)
            return mac_path
        "Linux":
            var linux_path := _first_existing_path(LINUX_CODE_CANDIDATES)
            return linux_path
        "Windows":
            var win_candidates := _expand_windows_candidates()
            var win_path := _first_existing_path(win_candidates)
            return win_path
        _:
            pass

    return ""

func _connect_file_system_signals():
    if _fs_dock == null:
        return

    if _fs_dock.has_signal("files_opened"):
        var callable := Callable(self, "_on_files_opened")
        if not _fs_dock.is_connected("files_opened", callable):
            _fs_dock.connect("files_opened", callable)

    if _fs_dock.has_signal("file_opened"):
        var callable_file := Callable(self, "_on_file_opened")
        if not _fs_dock.is_connected("file_opened", callable_file):
            _fs_dock.connect("file_opened", callable_file)

    if _fs_dock.has_signal("file_open_requested"):
        var callable_request := Callable(self, "_on_file_open_requested")
        if not _fs_dock.is_connected("file_open_requested", callable_request):
            _fs_dock.connect("file_open_requested", callable_request)

    var tree_callable := Callable(self, "_on_tree_item_activated")
    for tree in _fs_trees:
        if tree and not tree.is_connected("item_activated", tree_callable):
            tree.connect("item_activated", tree_callable)

func _disconnect_file_system_signals():
    if _fs_dock == null:
        return

    if _fs_dock.has_signal("files_opened"):
        var callable := Callable(self, "_on_files_opened")
        if _fs_dock.is_connected("files_opened", callable):
            _fs_dock.disconnect("files_opened", callable)

    if _fs_dock.has_signal("file_opened"):
        var callable_file := Callable(self, "_on_file_opened")
        if _fs_dock.is_connected("file_opened", callable_file):
            _fs_dock.disconnect("file_opened", callable_file)

    if _fs_dock.has_signal("file_open_requested"):
        var callable_request := Callable(self, "_on_file_open_requested")
        if _fs_dock.is_connected("file_open_requested", callable_request):
            _fs_dock.disconnect("file_open_requested", callable_request)

    var tree_callable := Callable(self, "_on_tree_item_activated")
    for tree in _fs_trees:
        if tree and tree.is_connected("item_activated", tree_callable):
            tree.disconnect("item_activated", tree_callable)

func _on_files_opened(paths):
    if paths is PackedStringArray or paths is Array:
        for path in paths:
            _open_path_in_vscode(str(path))

func _on_file_opened(path):
    _open_path_in_vscode(str(path))

func _on_file_open_requested(path):
    _open_path_in_vscode(str(path))

func _on_tree_item_activated(_item = null, _column = 0):
    var path := _get_selected_resource_path(get_editor_interface())
    if _should_skip_tree_activation(path):
        return
    _open_path_in_vscode(path)

func _open_path_in_vscode(path: String):
    if path.is_empty():
        return
    if _should_skip_open(path):
        return

    var resource_path := _strip_resource_suffix(path)
    var absolute_path := ProjectSettings.globalize_path(resource_path)
    if absolute_path.is_empty():
        push_warning("Cannot resolve absolute path for %s." % resource_path)
        return

    if not FileAccess.file_exists(absolute_path):
        push_warning("File %s does not exist on disk." % absolute_path)
        return

    var project_root := ProjectSettings.globalize_path("res://")
    if project_root.is_empty():
        push_warning("Cannot determine project root for %s." % path)
        return

    if not DirAccess.dir_exists_absolute(project_root):
        push_warning("Project root path %s does not exist." % project_root)
        return

    var vscode_path := _resolve_vscode_path()
    if vscode_path.is_empty():
        push_error("VSCode CLI not found. Run 'Shell Command: Install code in PATH' in VSCode.")
        return

    var args := PackedStringArray()
    args.append("--reuse-window")
    args.append(project_root)
    args.append(absolute_path)
    var exit_code := OS.execute(vscode_path, args)
    if exit_code != 0:
        push_warning("VSCode CLI returned exit code %d when opening %s." % [exit_code, project_root])
        return

    print("Opened in VSCode:", absolute_path)

func _find_code_in_path() -> String:
    var os_name := OS.get_name()
    var locator := ""
    match os_name:
        "Windows":
            locator = "where"
        "macOS", "Linux":
            locator = "which"
        _:
            return ""

    var output := []
    var exit_code := OS.execute(locator, PackedStringArray(["code"]), output, true)
    if exit_code != 0 or output.is_empty():
        return ""

    var fallback := ""
    for line in output:
        var candidate := str(line).strip_edges()
        if candidate.is_empty():
            continue
        if candidate.ends_with(".exe") and FileAccess.file_exists(candidate):
            return candidate
        if FileAccess.file_exists(candidate) and fallback.is_empty():
            fallback = candidate
    return fallback

func _first_existing_path(candidates: Array) -> String:
    for candidate in candidates:
        var path := str(candidate)
        if path.is_empty():
            continue
        if FileAccess.file_exists(path):
            return path
    return ""

func _expand_windows_candidates() -> Array:
    var expanded: Array = []
    for raw_path in WINDOWS_CODE_CANDIDATES:
        var expanded_path := _expand_windows_path(str(raw_path))
        if not expanded_path.is_empty():
            expanded.append(expanded_path)
    return expanded

func _expand_windows_path(path: String) -> String:
    var replacements := {
        "%LOCALAPPDATA%": OS.get_environment("LOCALAPPDATA"),
        "%ProgramFiles%": OS.get_environment("ProgramFiles"),
        "%ProgramFiles(x86)%": OS.get_environment("ProgramFiles(x86)")
    }

    var result := path
    for key in replacements.keys():
        var value = replacements[key]
        if value.is_empty():
            continue
        result = result.replace(key, value)
    return result

func _find_all_trees(node: Node) -> Array:
    var result: Array = []
    _collect_trees(node, result)
    return result

func _collect_trees(node: Node, result: Array) -> void:
    if node is Tree:
        result.append(node)
    for child in node.get_children():
        _collect_trees(child, result)

func _should_skip_tree_activation(path: String) -> bool:
    return _should_skip_open(path)

func _should_skip_open(path: String) -> bool:
    if path.is_empty():
        return false
    var resource_path := _strip_resource_suffix(path)
    var lowered := resource_path.to_lower()
    var is_dir := _is_directory(resource_path)
    var is_tscn := lowered.ends_with(".tscn")
    if is_dir:
        return true
    if is_tscn:
        return true
    return false

func _is_directory(path: String) -> bool:
    var normalized_path := _strip_resource_suffix(path)
    var absolute_path := ProjectSettings.globalize_path(normalized_path)
    if absolute_path.is_empty():
        return false
    var exists := DirAccess.dir_exists_absolute(absolute_path)
    return exists

func _strip_resource_suffix(path: String) -> String:
    var suffix_index := path.find("::")
    if suffix_index == -1:
        return path
    var stripped := path.substr(0, suffix_index)
    return stripped
