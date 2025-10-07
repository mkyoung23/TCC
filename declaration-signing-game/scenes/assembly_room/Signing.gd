extends Node3D

enum SigningState {
	SETUP,
	CEREMONY_START,
	HANCOCK_SIGNING,
	COLONY_QUEUE,
	SIGNING_COMPLETE,
	EPILOGUE_TRANSITION
}

var game_manager: GameManager
var current_state: SigningState = SigningState.SETUP
var colonies_signed: int = 0
var total_colonies: int = 13

@onready var player = $Player
@onready var clerks_table = $ClerksTable/ClerksTableInteractable
@onready var lectern = $InformationLectern/LecternInteractable
@onready var signing_marker = $SigningMarker/MarkerInteractable
@onready var dialogue_system = $DialogueSystem
@onready var sequence_timer = $SigningSequence/SequenceTimer
@onready var progress_panel = $UI/SigningProgress
@onready var progress_text = $UI/SigningProgress/ProgressContent/ProgressText
@onready var evidence_note = $UI/EvidenceNote
@onready var evidence_text = $UI/EvidenceNote/EvidenceContent/EvidenceText

func _ready():
	game_manager = GameManager.new()
	setup_assembly_room()
	start_signing_sequence()

func setup_assembly_room():
	clerks_table.prompt_text = "Clerks' table with engrossed parchment"
	clerks_table.source_id = "matlack_engrossing"
	clerks_table.interacted.connect(_on_clerks_table_interacted)
	
	lectern.prompt_text = "Press E to read room layout information"
	lectern.source_id = "assembly_room_reconstruction"
	lectern.interacted.connect(_on_lectern_interacted)
	
	signing_marker.prompt_text = "Hancock's signing position"
	signing_marker.source_id = "hancock_signs_first"
	signing_marker.interacted.connect(_on_signing_marker_interacted)
	
	sequence_timer.timeout.connect(_on_sequence_timer_timeout)
	
	# Show evidence note
	evidence_note.visible = true
	evidence_text.text = """Assembly Room Layout - Best Evidence Reconstruction

KNOWN ELEMENTS:
• Green baize-covered tables
• Windsor chairs  
• Chandelier
• Folding screens in front corners
• East and west windows

NOTE: Exact seating arrangement unknown. This reconstruction based on room dimensions and period descriptions.

[Sources: NPS Assembly Room furnishings]"""

func start_signing_sequence():
	current_state = SigningState.SETUP
	progress_panel.visible = true
	progress_text.text = "Delegates gathering for signing ceremony..."
	
	sequence_timer.wait_time = 3.0
	sequence_timer.start()

func _on_sequence_timer_timeout():
	match current_state:
		SigningState.SETUP:
			begin_ceremony()
		SigningState.CEREMONY_START:
			hancock_signs()
		SigningState.HANCOCK_SIGNING:
			start_colony_queue()
		SigningState.COLONY_QUEUE:
			continue_colony_signing()
		SigningState.SIGNING_COMPLETE:
			transition_to_epilogue()

func begin_ceremony():
	current_state = SigningState.CEREMONY_START
	progress_text.text = "Timothy Matlack presents the engrossed parchment..."
	
	var ceremony_dialogue = [
		{
			"speaker": "Timothy Matlack",
			"text": "Gentlemen, the engrossed copy of the Declaration is ready for your signatures.",
			"source_id": "matlack_clerk_role"
		},
		{
			"speaker": "John Hancock", 
			"text": "As President of the Congress, I shall sign first.",
			"source_id": "hancock_president_role"
		}
	]
	
	dialogue_system.start_dialogue(ceremony_dialogue)
	dialogue_system.dialogue_finished.connect(_on_ceremony_dialogue_finished)
	
	sequence_timer.wait_time = 8.0
	sequence_timer.start()

func _on_ceremony_dialogue_finished():
	dialogue_system.dialogue_finished.disconnect(_on_ceremony_dialogue_finished)

func hancock_signs():
	current_state = SigningState.HANCOCK_SIGNING
	progress_text.text = "John Hancock signs first with his famous large signature..."
	
	# Focus camera on signing area (if camera system exists)
	show_hancock_signing_effect()
	
	var hancock_dialogue = []
	
	# Add legend dialogue if legend mode is on
	if game_manager.game_state.legend_mode:
		hancock_dialogue.append({
			"speaker": "John Hancock",
			"text": "There, I guess King George will be able to read that!",
			"source_id": "hancock_signature_legend",
			"legend_only": true
		})
	
	hancock_dialogue.append({
		"speaker": "Narrator",
		"text": "Hancock signs with a bold, large signature as President of the Continental Congress.",
		"source_id": "hancock_signs_first_aug2"
	})
	
	if hancock_dialogue.size() > 0:
		dialogue_system.start_dialogue(hancock_dialogue)
		dialogue_system.dialogue_finished.connect(_on_hancock_dialogue_finished)
	
	sequence_timer.wait_time = 6.0
	sequence_timer.start()

func _on_hancock_dialogue_finished():
	dialogue_system.dialogue_finished.disconnect(_on_hancock_dialogue_finished)

func show_hancock_signing_effect():
	# Visual effect for Hancock's signature
	var signature_label = Label.new()
	signature_label.text = "✍ JOHN HANCOCK - President"
	signature_label.position = Vector2(300, 200)
	signature_label.modulate = Color.GOLD
	signature_label.add_theme_color_override("font_color", Color.GOLD)
	player.get_node("UI").add_child(signature_label)
	
	var timer = Timer.new()
	timer.wait_time = 4.0
	timer.one_shot = true
	timer.timeout.connect(func():
		if is_instance_valid(signature_label):
			signature_label.queue_free()
		timer.queue_free()
	)
	add_child(timer)
	timer.start()

func start_colony_queue():
	current_state = SigningState.COLONY_QUEUE
	colonies_signed = 0
	progress_text.text = "Delegates signing by colony delegation..."
	
	var queue_dialogue = [
		{
			"speaker": "Narrator",
			"text": "Delegates now approach by colony to add their signatures to the engrossed parchment.",
			"source_id": "signing_process_aug2"
		}
	]
	
	dialogue_system.start_dialogue(queue_dialogue)
	dialogue_system.dialogue_finished.connect(_on_queue_dialogue_finished)
	
	sequence_timer.wait_time = 4.0
	sequence_timer.start()

func _on_queue_dialogue_finished():
	dialogue_system.dialogue_finished.disconnect(_on_queue_dialogue_finished)

func continue_colony_signing():
	colonies_signed += 1
	
	var colony_names = [
		"New Hampshire", "Massachusetts", "Rhode Island", "Connecticut",
		"New York", "New Jersey", "Pennsylvania", "Delaware", 
		"Maryland", "Virginia", "North Carolina", "South Carolina", "Georgia"
	]
	
	if colonies_signed <= colony_names.size():
		var colony_name = colony_names[colonies_signed - 1]
		progress_text.text = "Signing: " + colony_name + " delegation (" + str(colonies_signed) + "/" + str(total_colonies) + ")"
		
		sequence_timer.wait_time = 2.5
		sequence_timer.start()
	else:
		complete_signing()

func complete_signing():
	current_state = SigningState.SIGNING_COMPLETE
	progress_text.text = "Signing ceremony complete! Most delegates have signed."
	
	game_manager.witness_signing()
	
	var completion_dialogue = [
		{
			"speaker": "Narrator",
			"text": "The majority of delegates have now signed the engrossed Declaration of Independence.",
			"source_id": "aug2_signing_completion"
		},
		{
			"speaker": "Narrator", 
			"text": "Some delegates will sign later when they arrive in Philadelphia.",
			"source_id": "late_signers_note"
		}
	]
	
	dialogue_system.start_dialogue(completion_dialogue)
	dialogue_system.dialogue_finished.connect(_on_completion_dialogue_finished)
	
	sequence_timer.wait_time = 8.0
	sequence_timer.start()

func _on_completion_dialogue_finished():
	dialogue_system.dialogue_finished.disconnect(_on_completion_dialogue_finished)

func transition_to_epilogue():
	current_state = SigningState.EPILOGUE_TRANSITION
	progress_text.text = "Transitioning to New York epilogue..."
	
	var transition_timer = Timer.new()
	transition_timer.wait_time = 3.0
	transition_timer.one_shot = true
	transition_timer.timeout.connect(func():
		game_manager.start_epilogue()
		transition_timer.queue_free()
	)
	add_child(transition_timer)
	transition_timer.start()

func _on_clerks_table_interacted():
	var table_message = "Timothy Matlack's engrossed parchment on vellum. The formal copy for signatures. [matlack_engrossing_process]"
	show_room_message(table_message)

func _on_lectern_interacted():
	var layout_info = """ASSEMBLY ROOM LAYOUT INFORMATION

This reconstruction is based on:
• Known room dimensions (40' x 40')  
• Period descriptions of furnishings
• Archaeological evidence
• National Park Service research

CONFIRMED ELEMENTS:
• Green baize table covering
• Windsor chairs
• Chandelier for lighting
• Folding screens in corners
• East/west window placement

UNKNOWN: Exact seating arrangement of delegates

[Source: NPS Assembly Room historical research]"""
	
	show_detailed_info(layout_info)

func _on_signing_marker_interacted():
	var marker_message = "John Hancock signed first as President of the Continental Congress, August 2, 1776. [hancock_signs_first]"
	show_room_message(marker_message)

func show_room_message(message: String):
	var temp_label = Label.new()
	temp_label.text = message
	temp_label.position = Vector2(50, 300)
	temp_label.modulate = Color.WHITE
	temp_label.add_theme_color_override("font_color", Color.WHITE)
	temp_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	player.get_node("UI").add_child(temp_label)
	
	var timer = Timer.new()
	timer.wait_time = 4.0
	timer.one_shot = true
	timer.timeout.connect(func():
		if is_instance_valid(temp_label):
			temp_label.queue_free()
		timer.queue_free()
	)
	add_child(timer)
	timer.start()

func show_detailed_info(info: String):
	evidence_text.text = info
	evidence_note.visible = true
	
	var hide_timer = Timer.new()
	hide_timer.wait_time = 10.0
	hide_timer.one_shot = true  
	hide_timer.timeout.connect(func():
		evidence_note.visible = false
		hide_timer.queue_free()
	)
	add_child(hide_timer)
	hide_timer.start()