extends Control
class_name DialogueSystem

signal dialogue_finished
signal dialogue_advanced(line_index: int)

@export var auto_advance_time: float = 3.0
@export var show_subtitles: bool = true
@export var show_source_tags: bool = true

var current_dialogue: Array[Dictionary] = []
var current_line_index: int = 0
var is_dialogue_active: bool = false
var auto_advance_timer: Timer

@onready var dialogue_panel = $DialoguePanel
@onready var speaker_label = $DialoguePanel/VBoxContainer/SpeakerLabel
@onready var dialogue_text = $DialoguePanel/VBoxContainer/DialogueText
@onready var source_tag = $DialoguePanel/VBoxContainer/SourceTag
@onready var continue_label = $DialoguePanel/VBoxContainer/ContinueLabel

func _ready():
	setup_dialogue_ui()
	setup_auto_advance_timer()

func setup_dialogue_ui():
	dialogue_panel.visible = false
	continue_label.text = "Press SPACE to continue"

func setup_auto_advance_timer():
	auto_advance_timer = Timer.new()
	auto_advance_timer.wait_time = auto_advance_time
	auto_advance_timer.timeout.connect(_on_auto_advance_timeout)
	auto_advance_timer.one_shot = true
	add_child(auto_advance_timer)

func start_dialogue(dialogue_data: Array[Dictionary]):
	current_dialogue = dialogue_data
	current_line_index = 0
	is_dialogue_active = true
	dialogue_panel.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	display_current_line()

func display_current_line():
	if current_line_index >= current_dialogue.size():
		end_dialogue()
		return
	
	var line = current_dialogue[current_line_index]
	
	speaker_label.text = line.get("speaker", "")
	dialogue_text.text = line.get("text", "")
	
	if show_source_tags and line.has("source_id"):
		source_tag.text = "[" + line.source_id + "]"
		source_tag.visible = true
	else:
		source_tag.visible = false
	
	dialogue_advanced.emit(current_line_index)
	
	# Start auto-advance timer if enabled
	if auto_advance_time > 0:
		auto_advance_timer.start()

func _input(event):
	if is_dialogue_active and Input.is_action_just_pressed("continue"):
		advance_dialogue()

func advance_dialogue():
	auto_advance_timer.stop()
	current_line_index += 1
	display_current_line()

func end_dialogue():
	is_dialogue_active = false
	dialogue_panel.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	current_dialogue.clear()
	current_line_index = 0
	dialogue_finished.emit()

func _on_auto_advance_timeout():
	advance_dialogue()

# Utility function to load dialogue from JSON
func load_dialogue_from_file(file_path: String) -> Array[Dictionary]:
	if not FileAccess.file_exists(file_path):
		print("Dialogue file not found: ", file_path)
		return []
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		print("Error parsing dialogue JSON: ", file_path)
		return []
	
	return json.data

# Create dialogue data structure for historical events
func create_historical_dialogue(event_name: String) -> Array[Dictionary]:
	var historical_dialogues = {
		"hancock_signs": [
			{
				"speaker": "John Hancock",
				"text": "There, I guess King George will be able to read that.",
				"source_id": "hancock_signature_legend",
				"legend_only": true
			}
		],
		"signing_ceremony": [
			{
				"speaker": "Narrator", 
				"text": "The delegates approach the clerk's table to sign the engrossed parchment.",
				"source_id": "archives_signing_process"
			},
			{
				"speaker": "Timothy Matlack",
				"text": "The document is ready for your signatures, gentlemen.",
				"source_id": "matlack_clerk_role"
			}
		],
		"nixon_reading": [
			{
				"speaker": "John Nixon",
				"text": "When in the Course of human events...",
				"source_id": "first_public_reading_jul8"
			}
		],
		"washington_orders": [
			{
				"speaker": "George Washington",
				"text": "The Continental Congress having declared the United States free and independent...",
				"source_id": "washington_general_orders_jul9"
			}
		]
	}
	
	return historical_dialogues.get(event_name, [])