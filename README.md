# ThoughtBubblesV5

This version has a focus on creative writing applications. It uses JSON for data handling and stores all data locally.

ThoughtBubbles is built with Godot 4



Todo:

- [ ] Switch to pure JSON for data handling
- [ ] Comment Code and create documentation sheet
- [ ] Basic flow chart
- [ ] Update UI Styling for Writing Focus

10/16/25

Returning to this project after a long haietus. Will focus in implementing local linked json data. I can later work on a script that syncs the json with a server, but that doesn't need to be implemented in godot. Linked data should be a standard format that I will use in many projects, and the syncing script will just look at it and sync it and can be dropped into any project.

If making a build, maybe having a syncing script run by godot would be useful? Regardless, local files are all I care about right now.

will remove any orbitdb and neo4j reference, as linked json is the source truth data. If I use other databases later I can reference them to export linked json for this app to injest.

For saving, a ndjson log of all actions should be kept for reference and future processing, and thoughts should be saved as individual jsonld files in a directory

10/20
Thought bubbles should save with all relevant context, and only when a new context is discovered should irrelevant properties (to one or any context) be externalized as their own thoughts