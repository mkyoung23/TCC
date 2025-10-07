extends Node3D

enum ReadingState {
	SETUP,
	CROWD_GATHERING,
	NIXON_INTRODUCTION,
	DECLARATION_READING,
	CROWD_REACTION,
	LEGEND_DISCUSSION,
	FLASHBACK_END
}

var game_manager: GameManager
var current_state: ReadingState = ReadingState.SETUP

@onready var player = $Player
@onready var podium = $StateHouseYard/ReadingPodium/PodiumInteractable
@onready var nixon_marker = $StateHouseYard/NixonPosition/NixonMarker
@onready var bell_interactable = $StateHouseYard/LibertyBellTower/BellInteractable
@onready var crowd_marker1 = $StateHouseYard/CrowdArea1/CrowdMarker1
@onready var crowd_marker2 = $StateHouseYard/CrowdArea2/CrowdMarker2
@onready var crowd_marker3 = $StateHouseYard/CrowdArea3/CrowdMarker3
@onready var dialogue_system = $DialogueSystem
@onready var sequence_timer = $ReadingSequence/SequenceTimer
@onready var flashback_overlay = $UI/FlashbackOverlay
@onready var legend_panel = $UI/LegendPanel
@onready var legend_text = $UI/LegendPanel/LegendContent/LegendText
@onready var progress_panel = $UI/ReadingProgress
@onready var progress_text = $UI/ReadingProgress/ProgressContent/ProgressText

func _ready():
	game_manager = GameManager.new()
	setup_reading_scene()
	start_flashback_sequence()

func setup_reading_scene():
	podium.prompt_text = "Reading podium - July 8, 1776"
	podium.source_id = "first_public_reading_podium"
	podium.interacted.connect(_on_podium_interacted)
	
	nixon_marker.prompt_text = "John Nixon's position"
	nixon_marker.source_id = "nixon_reader_jul8"
	nixon_marker.interacted.connect(_on_nixon_marker_interacted)
	
	bell_interactable.prompt_text = "Liberty Bell tower"
	bell_interactable.source_id = "liberty_bell_legend"
	bell_interactable.legend_only = true
	bell_interactable.interacted.connect(_on_bell_interacted)
	
	crowd_marker1.prompt_text = "Crowd gathering area"
	crowd_marker1.source_id = "public_reading_attendance"
	crowd_marker1.interacted.connect(_on_crowd_interacted.bind(1))
	
	crowd_marker2.prompt_text = "Citizens listening to reading"
	crowd_marker2.source_id = "public_reading_attendance"
	crowd_marker2.interacted.connect(_on_crowd_interacted.bind(2))
	
	crowd_marker3.prompt_text = "Assembled townspeople"
	crowd_marker3.source_id = "public_reading_attendance"  
	crowd_marker3.interacted.connect(_on_crowd_interacted.bind(3))
	
	sequence_timer.timeout.connect(_on_sequence_timer_timeout)

func start_flashback_sequence():
	current_state = ReadingState.SETUP
	
	# Show flashback overlay briefly
	var overlay_timer = Timer.new()
	overlay_timer.wait_time = 3.0
	overlay_timer.one_shot = true
	overlay_timer.timeout.connect(func():
		flashback_overlay.visible = false
		overlay_timer.queue_free()
	)
	add_child(overlay_timer)
	overlay_timer.start()
	
	progress_panel.visible = true
	progress_text.text = "July 8, 1776 - State House Yard"
	
	sequence_timer.wait_time = 4.0
	sequence_timer.start()

func _on_sequence_timer_timeout():
	match current_state:
		ReadingState.SETUP:
			gather_crowd()
		ReadingState.CROWD_GATHERING:
			introduce_nixon()
		ReadingState.NIXON_INTRODUCTION:
			begin_reading()
		ReadingState.DECLARATION_READING:
			crowd_reacts()
		ReadingState.CROWD_REACTION:
			discuss_legend()
		ReadingState.LEGEND_DISCUSSION:
			end_flashback()

func gather_crowd():
	current_state = ReadingState.CROWD_GATHERING
	progress_text.text = "Citizens gathering in the State House yard..."
	
	var crowd_dialogue = [
		{
			"speaker": "Narrator",
			"text": "Citizens of Philadelphia gather in the State House yard on the afternoon of July 8, 1776.",
			"source_id": "july8_public_reading"
		},
		{
			"speaker": "Narrator",
			"text": "This will be the first public reading of the newly adopted Declaration of Independence.",
			"source_id": "first_public_reading_jul8"
		}
	]
	
	dialogue_system.start_dialogue(crowd_dialogue)
	dialogue_system.dialogue_finished.connect(_on_crowd_dialogue_finished)
	
	sequence_timer.wait_time = 8.0
	sequence_timer.start()

func _on_crowd_dialogue_finished():
	dialogue_system.dialogue_finished.disconnect(_on_crowd_dialogue_finished)

func introduce_nixon():
	current_state = ReadingState.NIXON_INTRODUCTION
	progress_text.text = "John Nixon approaches the podium..."
	
	var nixon_dialogue = [
		{
			"speaker": "Narrator",
			"text": "John Nixon, a member of the Committee of Safety, steps forward to read the Declaration.",
			"source_id": "nixon_reader_background"
		}
	]
	
	dialogue_system.start_dialogue(nixon_dialogue)
	dialogue_system.dialogue_finished.connect(_on_nixon_dialogue_finished)
	
	sequence_timer.wait_time = 5.0
	sequence_timer.start()

func _on_nixon_dialogue_finished():
	dialogue_system.dialogue_finished.disconnect(_on_nixon_dialogue_finished)

func begin_reading():
	current_state = ReadingState.DECLARATION_READING
	progress_text.text = "John Nixon begins reading the Declaration..."
	
	var reading_dialogue = [
		{
			"speaker": "John Nixon",
			"text": "When in the Course of human events, it becomes necessary for one people to dissolve the political bands...",
			"source_id": "declaration_opening_jul8"
		},
		{
			"speaker": "Narrator",
			"text": "Nixon's voice carries across the yard as he reads the full text of the Declaration to the assembled crowd.",
			"source_id": "nixon_reading_process"
		}
	]
	
	dialogue_system.start_dialogue(reading_dialogue)
	dialogue_system.dialogue_finished.connect(_on_reading_dialogue_finished)
	
	sequence_timer.wait_time = 10.0
	sequence_timer.start()

func _on_reading_dialogue_finished():
	dialogue_system.dialogue_finished.disconnect(_on_reading_dialogue_finished)

func crowd_reacts():
	current_state = ReadingState.CROWD_REACTION
	progress_text.text = "The crowd reacts to hearing the Declaration..."
	
	var reaction_dialogue = [
		{
			"speaker": "Narrator",
			"text": "The crowd cheers as Nixon concludes the reading. Philadelphia has heard its declaration of independence.",
			"source_id": "crowd_reaction_jul8"
		}
	]
	
	dialogue_system.start_dialogue(reaction_dialogue)
	dialogue_system.dialogue_finished.connect(_on_reaction_dialogue_finished)
	
	sequence_timer.wait_time = 6.0
	sequence_timer.start()

func _on_reaction_dialogue_finished():
	dialogue_system.dialogue_finished.disconnect(_on_reaction_dialogue_finished)

func discuss_legend():
	current_state = ReadingState.LEGEND_DISCUSSION
	progress_text.text = "Historical note about the Liberty Bell..."
	
	# Show legend panel
	legend_panel.visible = true
	
	var legend_dialogue = [
		{
			"speaker": "Historical Note",
			"text": "Popular legend claims the Liberty Bell rang to announce this reading, but no contemporary accounts mention bell ringing on July 8.",
			"source_id": "liberty_bell_myth_analysis"
		},
		{
			"speaker": "Historical Note", 
			"text": "The Liberty Bell legend appears to have originated in 19th-century stories, not 1776 accounts.",
			"source_id": "bell_legend_origins"
		}
	]
	
	dialogue_system.start_dialogue(legend_dialogue)
	dialogue_system.dialogue_finished.connect(_on_legend_dialogue_finished)
	
	sequence_timer.wait_time = 12.0
	sequence_timer.start()

func _on_legend_dialogue_finished():
	dialogue_system.dialogue_finished.disconnect(_on_legend_dialogue_finished)

func end_flashback():
	current_state = ReadingState.FLASHBACK_END
	progress_text.text = "Returning to August 2nd..."
	
	var end_dialogue = [
		{
			"speaker": "Narrator",
			"text": "This first public reading began spreading the news of America's declared independence throughout the colonies.",
			"source_id": "reading_significance"
		}
	]
	
	dialogue_system.start_dialogue(end_dialogue)
	dialogue_system.dialogue_finished.connect(_on_end_dialogue_finished)
	
	# Transition back to main timeline
	var transition_timer = Timer.new()
	transition_timer.wait_time = 8.0
	transition_timer.one_shot = true
	transition_timer.timeout.connect(func():
		return_to_main_timeline()
		transition_timer.queue_free()
	)
	add_child(transition_timer)
	transition_timer.start()

func _on_end_dialogue_finished():
	dialogue_system.dialogue_finished.disconnect(_on_end_dialogue_finished)

func return_to_main_timeline():
	# Fade to black and return to signing scene or continue to epilogue
	game_manager.start_epilogue()

func _on_podium_interacted():
	var podium_message = "From this podium, John Nixon read the Declaration to the citizens of Philadelphia on July 8, 1776. [first_public_reading_location]"
	show_reading_message(podium_message)

func _on_nixon_marker_interacted():
	var nixon_message = "John Nixon, member of the Committee of Safety, chosen to read the Declaration aloud. [nixon_reader_selection]"
	show_reading_message(nixon_message)

func _on_bell_interacted():
	if game_manager.game_state.legend_mode:
		var bell_message = "LEGEND: The Liberty Bell rang to announce the reading. EVIDENCE: No contemporary accounts mention bell ringing on July 8. [liberty_bell_legend_vs_evidence]"
		show_reading_message(bell_message)
		legend_panel.visible = true
	else:
		var evidence_message = "Bell tower present, but no evidence of ringing during July 8 reading. Press L to see legend version. [liberty_bell_evidence]"
		show_reading_message(evidence_message)

func _on_crowd_interacted(crowd_number: int):
	var crowd_messages = [
		"Philadelphia citizens gathered to hear the first public reading of the Declaration.",
		"Townspeople and visitors assembled in the State House yard for the historic reading.",
		"The crowd listened as Nixon's voice carried the words of independence across the yard."
	]
	
	if crowd_number <= crowd_messages.size():
		var message = crowd_messages[crowd_number - 1] + " [public_reading_attendance]"
		show_reading_message(message)

func show_reading_message(message: String):
	var temp_label = Label.new()
	temp_label.text = message
	temp_label.position = Vector2(50, 400)
	temp_label.modulate = Color.YELLOW
	temp_label.add_theme_color_override("font_color", Color.YELLOW)
	temp_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	player.get_node("UI").add_child(temp_label)
	
	var timer = Timer.new()
	timer.wait_time = 5.0
	timer.one_shot = true
	timer.timeout.connect(func():
		if is_instance_valid(temp_label):
			temp_label.queue_free()
		timer.queue_free()
	)
	add_child(timer)
	timer.start()

func _input(event):
	if current_state == ReadingState.LEGEND_DISCUSSION:
		if Input.is_action_just_pressed("legend_toggle"):
			game_manager.toggle_legend_mode()
			update_legend_display()

func update_legend_display():
	if game_manager.game_state.legend_mode:
		legend_text.text = """LEGEND MODE: ON

The Liberty Bell rang out across Philadelphia to announce the Declaration reading, calling citizens to the State House yard.

NOTE: This is popular legend, not historical fact."""
	else:
		legend_text.text = """EVIDENCE MODE: ON

No contemporary accounts mention bell ringing on July 8, 1776. The Liberty Bell legend appears in 19th century stories.

[Press L to see legend version]"""