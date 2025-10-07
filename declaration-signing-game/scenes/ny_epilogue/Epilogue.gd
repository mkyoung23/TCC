extends Node3D

enum EpilogueState {
	INTRODUCTION,
	WASHINGTON_ORDERS,
	TROOPS_READING,
	CROWD_REACTION,
	BOWLING_GREEN_MONTAGE,
	CREDITS_ROLL
}

var game_manager: GameManager
var current_state: EpilogueState = EpilogueState.INTRODUCTION

@onready var player = $Player
@onready var command_tent = $NYScene/CommandTent/TentInteractable
@onready var troops_marker1 = $NYScene/TroopFormation1/TroopsMarker1
@onready var troops_marker2 = $NYScene/TroopFormation2/TroopsMarker2
@onready var troops_marker3 = $NYScene/TroopFormation3/TroopsMarker3
@onready var reading_platform = $NYScene/ReadingPlatform/PlatformInteractable
@onready var bowling_green_marker = $NYScene/BowlingGreenDirection/BowlingGreenMarker
@onready var dialogue_system = $DialogueSystem
@onready var sequence_timer = $EpilogueSequence/SequenceTimer
@onready var audio_player = $EpilogueSequence/AudioPlayer
@onready var epilogue_overlay = $UI/EpilogueOverlay
@onready var vo_subtitles = $UI/VOSubtitles
@onready var subtitle_text = $UI/VOSubtitles/SubtitleContent/SubtitleText
@onready var montage_panel = $UI/MontagePanel
@onready var montage_text = $UI/MontagePanel/MontageContent/MontageText
@onready var progress_panel = $UI/ProgressPanel
@onready var progress_text = $UI/ProgressPanel/ProgressContent/ProgressText

func _ready():
	game_manager = GameManager.new()
	setup_epilogue_scene()
	start_epilogue_sequence()

func setup_epilogue_scene():
	command_tent.prompt_text = "Washington's command headquarters"
	command_tent.source_id = "washington_ny_headquarters"
	command_tent.interacted.connect(_on_command_tent_interacted)
	
	troops_marker1.prompt_text = "Continental Army troops"
	troops_marker1.source_id = "continental_army_ny_1776"
	troops_marker1.interacted.connect(_on_troops_interacted.bind(1))
	
	troops_marker2.prompt_text = "Assembled soldiers"
	troops_marker2.source_id = "continental_army_ny_1776"
	troops_marker2.interacted.connect(_on_troops_interacted.bind(2))
	
	troops_marker3.prompt_text = "Military formation"
	troops_marker3.source_id = "continental_army_ny_1776"
	troops_marker3.interacted.connect(_on_troops_interacted.bind(3))
	
	reading_platform.prompt_text = "Platform for reading General Orders"
	reading_platform.source_id = "general_orders_reading"
	reading_platform.interacted.connect(_on_platform_interacted)
	
	bowling_green_marker.prompt_text = "Direction of Bowling Green"
	bowling_green_marker.source_id = "bowling_green_statue_location"
	bowling_green_marker.interacted.connect(_on_bowling_green_interacted)
	
	sequence_timer.timeout.connect(_on_sequence_timer_timeout)

func start_epilogue_sequence():
	current_state = EpilogueState.INTRODUCTION
	
	# Show epilogue overlay briefly
	var overlay_timer = Timer.new()
	overlay_timer.wait_time = 4.0
	overlay_timer.one_shot = true
	overlay_timer.timeout.connect(func():
		epilogue_overlay.visible = false
		overlay_timer.queue_free()
	)
	add_child(overlay_timer)
	overlay_timer.start()
	
	progress_panel.visible = true
	progress_text.text = "New York - July 9, 1776"
	
	sequence_timer.wait_time = 5.0
	sequence_timer.start()

func _on_sequence_timer_timeout():
	match current_state:
		EpilogueState.INTRODUCTION:
			present_washington_orders()
		EpilogueState.WASHINGTON_ORDERS:
			read_to_troops()
		EpilogueState.TROOPS_READING:
			troops_react()
		EpilogueState.CROWD_REACTION:
			bowling_green_montage()
		EpilogueState.BOWLING_GREEN_MONTAGE:
			roll_credits()

func present_washington_orders():
	current_state = EpilogueState.WASHINGTON_ORDERS
	progress_text.text = "Washington issues General Orders..."
	
	var orders_dialogue = [
		{
			"speaker": "Narrator",
			"text": "General George Washington receives word of the Declaration's adoption and prepares his General Orders for July 9, 1776.",
			"source_id": "washington_receives_declaration"
		},
		{
			"speaker": "Narrator", 
			"text": "Washington orders the Declaration to be read to all brigades and corps of the Continental Army.",
			"source_id": "washington_general_orders_jul9"
		}
	]
	
	dialogue_system.start_dialogue(orders_dialogue)
	dialogue_system.dialogue_finished.connect(_on_orders_dialogue_finished)
	
	sequence_timer.wait_time = 10.0
	sequence_timer.start()

func _on_orders_dialogue_finished():
	dialogue_system.dialogue_finished.disconnect(_on_orders_dialogue_finished)

func read_to_troops():
	current_state = EpilogueState.TROOPS_READING
	progress_text.text = "Reading the Declaration to the troops..."
	
	# Show VO subtitles
	vo_subtitles.visible = true
	
	# Washington's General Orders (paraphrased from historical source)
	var washington_orders = [
		{
			"speaker": "George Washington",
			"text": "The Continental Congress having declared the United States free and independent States...",
			"source_id": "washington_general_orders_jul9_text"
		},
		{
			"speaker": "George Washington",
			"text": "...the General hopes this important event will serve as fresh incentive to every officer and soldier...",
			"source_id": "washington_general_orders_jul9_text"
		},
		{
			"speaker": "George Washington",
			"text": "...to act with fidelity and courage, knowing that the peace and safety of their country depends upon their conduct.",
			"source_id": "washington_general_orders_jul9_text"
		}
	]
	
	dialogue_system.start_dialogue(washington_orders)
	dialogue_system.dialogue_finished.connect(_on_reading_dialogue_finished)
	
	# Display subtitles with source tags
	subtitle_text.text = "The Continental Congress having declared the United States free and independent States... [washington_general_orders_jul9]"
	
	sequence_timer.wait_time = 15.0
	sequence_timer.start()

func _on_reading_dialogue_finished():
	dialogue_system.dialogue_finished.disconnect(_on_reading_dialogue_finished)
	vo_subtitles.visible = false

func troops_react():
	current_state = EpilogueState.CROWD_REACTION
	progress_text.text = "The troops react to the news..."
	
	var reaction_dialogue = [
		{
			"speaker": "Narrator",
			"text": "The soldiers respond with three huzzahs for the United States of America.",
			"source_id": "troops_three_huzzahs"
		},
		{
			"speaker": "Continental Soldiers",
			"text": "Huzzah! Huzzah! Huzzah!",
			"source_id": "three_huzzahs_tradition"
		}
	]
	
	dialogue_system.start_dialogue(reaction_dialogue)
	dialogue_system.dialogue_finished.connect(_on_reaction_dialogue_finished)
	
	sequence_timer.wait_time = 8.0
	sequence_timer.start()

func _on_reaction_dialogue_finished():
	dialogue_system.dialogue_finished.disconnect(_on_reaction_dialogue_finished)

func bowling_green_montage():
	current_state = EpilogueState.BOWLING_GREEN_MONTAGE
	progress_text.text = "Bowling Green aftermath..."
	
	# Show montage panel
	montage_panel.visible = true
	
	var montage_dialogue = [
		{
			"speaker": "Narrator",
			"text": "Inspired by the Declaration, soldiers and citizens proceed to Bowling Green and topple the statue of King George III.",
			"source_id": "bowling_green_statue_toppling"
		},
		{
			"speaker": "Narrator",
			"text": "The lead from the royal statue will be melted down into musket balls for the Continental Army.",
			"source_id": "statue_lead_musket_balls"
		}
	]
	
	dialogue_system.start_dialogue(montage_dialogue)
	dialogue_system.dialogue_finished.connect(_on_montage_dialogue_finished)
	
	sequence_timer.wait_time = 12.0
	sequence_timer.start()

func _on_montage_dialogue_finished():
	dialogue_system.dialogue_finished.disconnect(_on_montage_dialogue_finished)

func roll_credits():
	current_state = EpilogueState.CREDITS_ROLL
	progress_text.text = "Experience complete"
	
	game_manager.complete_epilogue()
	
	# Hide all UI panels
	montage_panel.visible = false
	progress_panel.visible = false
	
	# Show credits
	show_credits()

func show_credits():
	var credits_panel = Panel.new()
	credits_panel.anchors_preset = Control.PRESET_FULL_RECT
	credits_panel.color = Color.BLACK
	player.get_node("UI").add_child(credits_panel)
	
	var credits_text = RichTextLabel.new()
	credits_text.anchors_preset = Control.PRESET_CENTER
	credits_text.offset_left = -400
	credits_text.offset_top = -300
	credits_text.offset_right = 400
	credits_text.offset_bottom = 300
	
	credits_text.text = """
[center]DECLARATION OF INDEPENDENCE: A HISTORICAL EXPERIENCE

Thank you for experiencing this recreation of July-August 1776

HISTORICAL CONSULTANTS:
• National Park Service - Independence Hall
• Library of Congress - American Memory Project  
• National Archives - Founding Documents
• Founders Online - University of Virginia

SOURCES CONSULTED:
• NPS Independence Hall Assembly Room research
• Founders Archives - Adams, Jefferson, Washington papers
• Library of Congress Philadelphia maps 1752-1777
• NARA Declaration of Independence timeline
• First public reading documentation July 8, 1776
• Washington General Orders July 9, 1776
• Bowling Green statue removal accounts

Generated with Claude Code
Co-Authored-By: Claude

For full source bibliography, see CITATIONS.md

[/center]
"""
	
	credits_text.fit_content = true
	credits_panel.add_child(credits_text)
	
	# Exit after credits
	var exit_timer = Timer.new()
	exit_timer.wait_time = 15.0
	exit_timer.one_shot = true
	exit_timer.timeout.connect(func():
		get_tree().change_scene_to_file("res://scenes/core/Main.tscn")
		exit_timer.queue_free()
	)
	add_child(exit_timer)
	exit_timer.start()

func _on_command_tent_interacted():
	var tent_message = "Washington's field headquarters in New York, July 1776. From here he issued the General Orders for reading the Declaration. [washington_ny_command]"
	show_epilogue_message(tent_message)

func _on_troops_interacted(troop_number: int):
	var troop_messages = [
		"Continental Army soldiers assembled to hear the Declaration read aloud.",
		"Troops from various colonies united under Washington's command.",
		"The army that would fight for the independence declared in Philadelphia."
	]
	
	if troop_number <= troop_messages.size():
		var message = troop_messages[troop_number - 1] + " [continental_army_composition_1776]"
		show_epilogue_message(message)

func _on_platform_interacted():
	var platform_message = "From this platform, Washington's officers read the Declaration to assembled troops on July 9, 1776. [general_orders_reading_ceremony]"
	show_epilogue_message(platform_message)

func _on_bowling_green_interacted():
	var bowling_green_message = "Direction to Bowling Green, where the statue of King George III stood until it was pulled down after the Declaration reading. [bowling_green_statue_history]"
	show_epilogue_message(bowling_green_message)

func show_epilogue_message(message: String):
	var temp_label = Label.new()
	temp_label.text = message
	temp_label.position = Vector2(50, 450)
	temp_label.modulate = Color.CYAN
	temp_label.add_theme_color_override("font_color", Color.CYAN)
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