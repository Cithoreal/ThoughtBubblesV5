# ThoughtBubbles V5

**A 3D spatial knowledge graph for creative writing and thought organization**

ThoughtBubbles is an innovative tool that reimagines how we organize and connect ideas by representing thoughts as interactive 3D objects in virtual space. Built for writers, researchers, and creative thinkers, it transforms the way you visualize relationships between concepts.

![Godot Engine](https://img.shields.io/badge/Godot-4.5-blue.svg)
![.NET](https://img.shields.io/badge/.NET-8.0-purple.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## 🎯 Purpose

ThoughtBubbles addresses the challenge of managing complex, interconnected ideas. Traditional note-taking tools impose linear or hierarchical structures, but creative thinking rarely follows such patterns. ThoughtBubbles lets you:

- **Visualize connections** between related thoughts in 3D space
- **Navigate context** by focusing on specific thought clusters
- **Track evolution** of ideas over time with timestamp-based versioning
- **Maintain flexibility** with a local-first, JSON-LD data model

The project is specifically designed for **creative writing applications**, where understanding the relationships between characters, plot points, themes, and world-building elements is crucial.

## ✨ Current Features

### Core Functionality
- ✅ **3D Thought Bubbles**: Create and position thoughts as interactive 3D objects
- ✅ **Linked Thinking**: Connect related thoughts with visual links
- ✅ **Spatial Organization**: Arrange thoughts in 3D space for intuitive navigation
- ✅ **Focus Mode**: Zoom into specific thought contexts to reduce cognitive load
- ✅ **Local Data Storage**: All data stored in JSON-LD format on your machine

### Data Management
- ✅ **JSON-LD Storage**: Each thought saved as a structured JSON-LD file
- ✅ **Timestamp Versioning**: Track changes to thoughts over time
- ✅ **Contextual Linking**: Thoughts maintain references to parent and child relationships
- ✅ **Property System**: Store rich metadata (position, color, shape, custom properties)

### Interaction
- ✅ **Free-fly Camera**: Navigate the 3D thought space freely
- ✅ **Customizable Appearance**: Change bubble colors and shapes
- ✅ **Dynamic Linking**: Create new thoughts linked to existing ones
- ✅ **Space Management**: Load, save, and clear thought spaces

## 🏗️ Technical Architecture

### Technology Stack
- **Engine**: Godot 4.5
- **Language**: GDScript with C# (.NET 8.0) support
- **Data Format**: JSON-LD (Linked Data)
- **Platform**: Cross-platform (desktop-focused)

### Project Structure
```
ThoughtBubblesV5/
├── Scripts/           # Core logic (GDScript)
│   ├── Space.gd      # Thought space management
│   ├── Bubble.gd     # Individual thought bubble logic
│   ├── Thought.gd    # Thought display interface
│   ├── thoughtbubble_store.gd  # Data storage abstraction
│   └── FileManager.gd           # JSON-LD file operations
├── Scenes/           # Godot scene files
│   ├── ThoughtBubble.tscn      # Bubble prefab
│   └── LineRenderer.tscn       # Link visualization
├── Files/
│   └── Thoughts/     # JSON-LD data storage
├── Assets/           # Media and resources
└── Main.tscn         # Main scene
```

### Data Model

ThoughtBubbles uses a graph-based data model where:

- **Thoughts** are nodes with unique IDs and properties
- **Links** are bidirectional edges (`LinkTo` and `LinkFrom`)
- **Context** is preserved through parent-child relationships
- **History** is maintained via timestamps

Example JSON-LD structure:
```json
{
  "@context": "/home/cithoreal/ThoughtBubbles/vocab/tb#",
  "@id": "Table",
  "data": "Table",
  "LinkFrom": ["Air_Hockey", "Text-Thought", ...],
  "LinkTo": [],
  "createdAt": "1762620020.17438",
  "lastUpdated": "1762620020.17438"
}
```

## 🚀 Getting Started

### Prerequisites
- Godot Engine 4.5 or later
- .NET 8.0 SDK (for C# support)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Cithoreal/ThoughtBubblesV5.git
   cd ThoughtBubblesV5
   ```

2. **Open in Godot**
   - Launch Godot 4.5
   - Import the project by selecting the `project.godot` file
   - Allow Godot to configure the C# environment

3. **Run the project**
   - Press F5 or click the "Play" button in Godot
   - The main scene will load with an example thought space

### Basic Usage

1. **Creating Thoughts**: Enter text in the "New Thought" field and click "Link New Thought"
2. **Navigating**: Use WASD keys to move, mouse to look around
3. **Focusing**: Select "Focus Thought" to zoom into a thought's context
4. **Saving**: Click "Save Space" to persist your thought space
5. **Loading**: Click "Load Space" to reload saved thoughts

## 📊 Current State

### What's Working
- ✅ Core 3D thought bubble creation and visualization
- ✅ Spatial positioning and navigation
- ✅ Thought linking system
- ✅ JSON-LD data persistence
- ✅ Timestamp-based versioning
- ✅ Focus mode for context isolation

### Known Limitations
- ⚠️ UI is developer-focused, not polished for end users
- ⚠️ Limited error handling for data corruption
- ⚠️ No undo/redo functionality
- ⚠️ Link visualization can become cluttered with many thoughts
- ⚠️ No search or filtering capabilities yet

### Development Status
This is an **active prototype** (V5) with focus on establishing a solid data model and core interaction patterns. The project prioritizes functionality over polish, making it suitable for:
- Early adopters comfortable with developer tools
- Experimentation with spatial knowledge graphs
- Personal creative writing projects
- Research into alternative note-taking paradigms

## 🗺️ Roadmap

### Short-term Goals
- [ ] Switch to pure JSON for data handling (in progress)
- [ ] Comprehensive code documentation
- [ ] Flow chart of system architecture
- [ ] UI styling update for writing focus
- [ ] Better link visualization

### Long-term Vision
- [ ] Search and filtering system
- [ ] Export to standard formats (markdown, PDF)
- [ ] Optional cloud sync capability
- [ ] Collaborative thought spaces
- [ ] VR/AR support for immersive thinking
- [ ] AI-assisted thought organization

## 🤝 Contributing

This is a personal project currently in active development. If you're interested in contributing or have ideas to share:

1. Open an issue to discuss proposed changes
2. Fork the repository
3. Create a feature branch
4. Submit a pull request with clear descriptions

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Copyright (c) 2020 RKiemGames

## 🔗 Related Concepts

- [Linked Data](https://www.w3.org/standards/semanticweb/data) - W3C Semantic Web standards
- [JSON-LD](https://json-ld.org/) - JSON for Linking Data
- [Zettelkasten](https://zettelkasten.de/) - Note-taking methodology
- [Knowledge Graphs](https://en.wikipedia.org/wiki/Knowledge_graph) - Structured knowledge representation

## 📧 Contact

For questions or discussions about ThoughtBubbles, please open an issue on GitHub.

---

**Note**: This is V5 of ThoughtBubbles, representing a significant shift toward local JSON-LD storage and creative writing applications. Previous versions explored different database backends (OrbitDB, Neo4j) which have been deprecated in favor of the current linked data approach.
