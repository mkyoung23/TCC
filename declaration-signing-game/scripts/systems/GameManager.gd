extends Node
class_name GameManager

signal scene_changed(scene_name: String)
signal character_selected(character_data: Dictionary)

var current_character: Dictionary
var game_state: Dictionary = {
	"current_scene": "character_select",
	"legend_mode": false,
	"sources_visible": false,
	"morning_routine_complete": false,
	"at_state_house": false,
	"signing_witnessed": false,
	"flashback_seen": false,
	"epilogue_complete": false
}

var available_characters = [
	{
		"id": "jefferson",
		"name": "Thomas Jefferson",
		"title": "Primary Author of the Declaration",
		"lodging": "Graff House (Declaration House)",
		"address": "700 Market Street (High Street)",
		"bio": "Virginia delegate and primary drafter of the Declaration. Lodged at Jacob Graff Jr.'s house while crafting the document that would change history.",
		"source_id": "nps_declaration_house",
		"morning_scene": "res://scenes/jefferson_morning/JeffersonMorning.tscn",
		"special_interaction": "thermometer"
	},
	{
		"id": "adams",
		"name": "John Adams", 
		"title": "Massachusetts Delegate",
		"lodging": "Mrs. Sarah Yard's Boarding House",
		"address": "Second Street",
		"bio": "Passionate advocate for independence from Massachusetts. Stayed at Mrs. Yard's boarding house during the Continental Congress sessions.",
		"source_id": "founders_archives_adams",
		"morning_scene": "res://scenes/adams_morning/AdamsMorning.tscn",
		"special_interaction": "correspondence"
	},
	{
		"id": "franklin",
		"name": "Benjamin Franklin",
		"title": "Pennsylvania Delegate & Elder Statesman", 
		"lodging": "Franklin Court",
		"address": "322 Market Street",
		"bio": "Renowned philosopher, inventor, and diplomat. At 70, the oldest signer, bringing wisdom and wit to the proceedings from his Philadelphia home.",
		"source_id": "nps_franklin_court",
		"morning_scene": "res://scenes/franklin_morning/FranklinMorning.tscn",
		"special_interaction": "printing_press"
	},
	{
		"id": "matlack",
		"name": "Timothy Matlack",
		"title": "Engrossing Clerk",
		"lodging": "Near the State House",
		"address": "Chestnut Street vicinity",
		"bio": "The skilled penman who engrossed the final parchment copy. Not a delegate but essential to creating the document we see today.",
		"source_id": "archives_matlack",
		"morning_scene": "res://scenes/matlack_morning/MatlackMorning.tscn", 
		"special_interaction": "quills"
	}
]

func _ready():
	# Initialize game systems
	pass

func select_character(character_id: String):
	for character in available_characters:
		if character.id == character_id:
			current_character = character
			game_state.current_scene = "morning_routine"
			character_selected.emit(character)
			return
	print("Error: Character not found: ", character_id)

func change_scene(scene_path: String):
	get_tree().change_scene_to_file(scene_path)
	var scene_name = scene_path.get_file().get_basename()
	game_state.current_scene = scene_name
	scene_changed.emit(scene_name)

func toggle_legend_mode():
	game_state.legend_mode = !game_state.legend_mode
	
func toggle_sources():
	game_state.sources_visible = !game_state.sources_visible

func complete_morning_routine():
	game_state.morning_routine_complete = true
	change_scene("res://scenes/philly_outdoor/PhillyStreets.tscn")

func arrive_at_state_house():
	game_state.at_state_house = true
	change_scene("res://scenes/assembly_room/Signing.tscn")

func witness_signing():
	game_state.signing_witnessed = true

func trigger_flashback():
	if not game_state.flashback_seen:
		game_state.flashback_seen = true
		change_scene("res://scenes/flashback_philly_reading/Reading.tscn")

func start_epilogue():
	change_scene("res://scenes/ny_epilogue/Epilogue.tscn")

func complete_epilogue():
	game_state.epilogue_complete = true