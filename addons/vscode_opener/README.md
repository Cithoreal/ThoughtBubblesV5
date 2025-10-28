# VSCode Opener

Open any file from the Godot 4 editor directly in Visual Studio Code. Once the plugin is enabled, a double-click on a file in the FileSystem dock (or the _Project → Tools → Open Selected File in VSCode_ command) launches the file in VS Code using its command line interface.

## Requirements

- Godot 4.5 or later.
- Visual Studio Code installed and launched at least once.
- VS Code CLI installed so the `code` command works in your shell (`⇧⌘P` → **Shell Command: Install 'code' command in PATH**, then verify with `code --version`).
- Supported platforms:
  - **macOS**: The plugin auto-detects `/usr/local/bin/code`, `/opt/homebrew/bin/code`, or the VS Code app bundle CLI.
  - **Windows**: The plugin checks `where code` and common install paths under `%LOCALAPPDATA%` and `%ProgramFiles%`.
  - **Linux**: The plugin looks for `code` via `which` and common locations like `/usr/bin/code` or `/snap/bin/code`.
- If you install VS Code somewhere unusual, update `_resolve_vscode_path()` in `vscode_opener.gd` with your custom path.

## Installation

1. Copy the `addons/vscode_opener` directory into your Godot project's `addons` folder.
2. In Godot, open **Project → Project Settings → Plugins**.
3. Enable **VSCode Opener**.

## Usage

- **Double-click** any file in the FileSystem dock to open it immediately in VS Code.
- Alternatively, select a file and choose **Project → Tools → Open Selected File in VSCode**.
- The plugin skips folders and reports issues in the editor Output panel if the CLI command fails.

## Asset Library Submission

- Zip only the `addons/vscode_opener` directory before uploading.
- Include the provided `icon.svg`, `plugin.cfg`, `README.md`, and `LICENSE` files in the archive.
- Set the asset category to **Editor**, mark compatibility with Godot 4.5+, and copy the feature list above into the asset description.
- Increment the `version` field in `plugin.cfg` for every release and mirror the same version number in the Asset Library entry.
- Add a short changelog and screenshots/GIFs when possible to comply with the Godot Asset Library guidelines.

## Troubleshooting

- If nothing opens, confirm that `code --version` works in a terminal and that the binary resides in one of the configured paths.
- Check the Godot Output panel or `~/Library/Application Support/Godot/editor.log` for messages from the plugin.
- Modify `_resolve_vscode_path()` in `vscode_opener.gd` if VS Code lives somewhere else on your system.

## License

MIT © Dewin-Vasil
