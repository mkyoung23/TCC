# Declaration of Independence: A Historical Experience

A historically accurate first-person narrative game recreating the signing of the Declaration of Independence on August 2, 1776, with flashbacks to the July 8 public reading and epilogue covering Washington's July 9 General Orders in New York.

## Quick Start

### Prerequisites
- **Godot Engine 4.2+** (Download from [godotengine.org](https://godotengine.org/))
- **Windows 11** (target platform, though may work on other OS)
- **Python 3.8+** (for asset downloader)

### Installation & Running

1. **Clone/Download** this project to your local machine
2. **Download Historical Assets** (recommended):
   ```bash
   cd tools
   python download_assets.py --project-root ..
   ```
3. **Open in Godot**:
   - Launch Godot Engine
   - Click "Import" and select the `project.godot` file
   - Click "Import & Edit"
4. **Run the Game**:
   - Press `F5` in Godot Editor
   - Select `Main.tscn` as the main scene if prompted

## Game Controls

### Movement
- **WASD** or **Arrow Keys**: Move around
- **Shift**: Sprint/Run faster  
- **Mouse**: Look around (first-person view)

### Interaction
- **E**: Interact with objects and people
- **Space**: Continue dialogue/advance text
- **J**: Open/close personal journal
- **M**: Toggle minimap (in outdoor scenes)
- **F1**: Show historical sources for current scene
- **L**: Toggle Legend Mode (shows popular legends vs. documented evidence)

### Accessibility
- **Subtitles**: Enabled by default with speaker names
- **Source Tags**: All dialogue shows source IDs like [source_id] when subtitles on
- **Volume Controls**: Available in settings menu

## Historical Experience Flow

### 1. Character Selection
Choose your historical perspective:
- **Thomas Jefferson**: Primary author, lodging at Graff House (Declaration House)
- **John Adams**: Independence advocate, staying at Mrs. Yard's boarding house  
- **Benjamin Franklin**: Elder statesman at age 70, residing at Franklin Court
- **Timothy Matlack**: Engrossing clerk who prepared the parchment copy

### 2. Morning Routine (August 2, 1776)
Begin your day in period-appropriate lodgings:
- Complete authentic morning activities
- Review historical materials and correspondence
- Prepare for the momentous day ahead

### 3. Philadelphia Streets
Navigate historically accurate 1776 Philadelphia:
- Walk from your lodging to the State House on Chestnut Street
- Explore Market Street (High Street), Second Street, and other period thoroughfares
- Visit key historical locations with documented information

### 4. Assembly Room Signing (Main Event)
Witness the formal signing ceremony:
- **Best-evidence reconstruction** of Assembly Room layout
- John Hancock signs first as President of Continental Congress
- Delegates sign by colony delegation
- Timothy Matlack's engrossed parchment on display
- **Note**: Seating arrangement marked as "exact layout unknown"

### 5. July 8 Flashback (Optional)
Experience the first public reading:
- John Nixon reads Declaration to Philadelphia citizens in State House yard
- **Legend vs. Evidence**: Liberty Bell legend addressed with toggle option
- Contemporary accounts vs. 19th-century stories

### 6. New York Epilogue (July 9, 1776)  
Washington's General Orders sequence:
- George Washington receives news in New York (he was NOT in Philadelphia)
- Declaration read to Continental Army troops
- Soldiers respond with "three huzzahs"
- Bowling Green statue aftermath montage

## Historical Accuracy Features

### What We Know vs. What's Uncertain

**✅ Confirmed by Multiple Sources:**
- August 2, 1776 formal signing date
- Hancock signed first with large signature
- Green baize table coverings, Windsor chairs, chandelier in Assembly Room
- July 8 public reading by John Nixon
- July 9 reading to Washington's troops

**❓ Best-Evidence Reconstruction:**
- Exact Assembly Room seating plan (clearly labeled as unknown)
- Daily routine details (based on period correspondence)
- Specific conversational content (paraphrased from documented sentiments)

**🧙‍♂️ Popular Legends (Legend Mode Only):**
- Hancock's "King George will read that" comment
- Liberty Bell ringing on July 8 (no contemporary evidence)

### Historical Methodology
- **No Fabricated Events**: Everything based on documented history or reasonable period inference
- **Source Transparency**: F1 key shows sources for every visible element  
- **Legend Identification**: Popular myths clearly marked and optional
- **Uncertainty Acknowledgment**: Gaps in historical record explicitly noted

## Performance Settings

Adjust these in the main menu Settings:

### Graphics Options
- **SDFGI (Global Illumination)**: Enhanced lighting (performance cost)
- **SSAO (Ambient Occlusion)**: Better shadow detail
- **MSAA**: Anti-aliasing levels (Disabled/2x/4x/8x)

### Recommended Settings
- **High-end PC**: All options enabled
- **Mid-range PC**: SDFGI on, SSAO on, 2x MSAA
- **Lower-end PC**: Disable SDFGI and SSAO, MSAA disabled

## Files and Structure

```
project/
├── scenes/           # Game scenes (character select, morning routines, signing, etc.)
├── scripts/          # GDScript code (player controller, systems, world logic)
├── assets/           # Historical maps, portraits, audio (populated by downloader)
├── data/             # JSON files with historical data and source references
├── tools/            # Python script to download historical assets
├── CITATIONS.md      # Complete bibliography of all sources used
└── project.godot     # Godot project configuration
```

## Source Documentation

Every element in this game is backed by historical documentation:

- **F1 in-game**: Shows sources for current scene elements
- **CITATIONS.md**: Complete human-readable bibliography  
- **data/SourceLog.json**: Machine-readable source database
- **NPS Documentation**: Independence Hall, Assembly Room research
- **Founders Online**: Adams, Jefferson, Washington papers
- **Library of Congress**: Period maps, documents, HABS architectural drawings
- **National Archives**: Official Declaration timeline and signing documentation

## What's Legend vs. What's Documented

### Toggle L to See the Difference

**Evidence-Based Mode (Default):**
- Shows only what can be documented from 1776 sources
- Acknowledges when historical record is incomplete
- Based on National Park Service research and primary documents

**Legend Mode (Press L):**
- Includes popular historical legends clearly marked as such
- Shows famous stories that lack contemporary evidence
- Explains how legends developed over time

### Examples:
- **Liberty Bell**: Legend says it rang July 8; evidence shows no contemporary accounts mention this
- **Hancock Quote**: "King George will read that" is popular legend, not documented
- **Assembly Room**: Exact seating unknown; game uses clearly marked best-evidence layout

## Technical Notes

### Asset Pipeline
1. **Historical Asset Downloader**: `python tools/download_assets.py`
   - Downloads public domain images from LoC, NPS, Wikimedia
   - Updates source log with metadata and citations
   - Verifies asset integrity
   
2. **Source Integration**: Every asset linked to SourceLog.json entries

3. **Performance Optimization**: 
   - LOD system for 3D models (if needed)
   - Texture compression for older hardware
   - Scalable lighting system

## Educational Use

This game is designed for:
- **History Education**: Accurate portrayal of 1776 events
- **Museums**: Interactive historical experience
- **Schools**: Teaching critical thinking about sources vs. legends
- **Public History**: Demonstrating historical methodology

### Classroom Integration
- **Source Analysis**: Students can examine F1 source overlay
- **Critical Thinking**: Compare Legend Mode vs. Evidence Mode
- **Research Skills**: Trace game elements to primary sources via CITATIONS.md

## Troubleshooting

### Common Issues

**Game Won't Start:**
- Ensure Godot 4.2+ is installed
- Check that project.godot file is valid
- Try importing the project fresh in Godot

**Performance Issues:**
- Lower graphics settings in main menu
- Disable SDFGI and SSAO
- Reduce MSAA level

**Missing Assets:**
- Run `python tools/download_assets.py` to fetch historical images
- Check internet connection for asset downloads
- Assets are optional; game runs with placeholders

**Controls Not Working:**
- Ensure game window has focus
- Check input map in Godot project settings
- Verify no conflicting input devices

## Contributing

### Reporting Historical Inaccuracies
We take historical accuracy seriously. To report issues:
1. Check current sources in CITATIONS.md and SourceLog.json
2. Provide specific citations for alternative interpretation
3. Submit with evidence from primary sources or official documentation

### Technical Contributions
- Follow GDScript style conventions
- Maintain source traceability for all historical elements
- Include citations for any new historical content

## Credits

### Historical Consultants
- **National Park Service** - Independence Hall Assembly Room research
- **Library of Congress** - American Memory Project maps and documents
- **National Archives** - Founding Documents timeline and analysis
- **Founders Online** - University of Virginia digitized papers project

### Development
- **Generated with Claude Code**
- **Co-Authored-By: Claude <noreply@anthropic.com>**

### Asset Sources
- Library of Congress (Public Domain historical materials)
- National Park Service (Historical documentation and research)
- Wikimedia Commons (Public Domain portraits and period images)
- National Archives (Official documentation and timelines)

## License

### Game Code
See LICENSE.txt for game code licensing terms.

### Historical Assets  
All historical materials are public domain or used under educational fair use. See SourceLog.json for specific attribution and licensing information for each asset.

### Educational Use Statement
This project is designed for educational and historical interpretation purposes. All content is based on documented historical sources with transparent attribution.

---

*For questions, issues, or historical source verification, please consult the comprehensive CITATIONS.md file and data/SourceLog.json database.*