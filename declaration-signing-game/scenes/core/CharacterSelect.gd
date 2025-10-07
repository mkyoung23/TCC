extends Control

var game_manager: GameManager

func _ready():
	game_manager = GameManager.new()
	setup_character_cards()

func setup_character_cards():
	var jefferson_button = $ScrollContainer/VBoxContainer/CharacterCards/JeffersonCard/JeffersonContent/SelectButton
	var adams_button = $ScrollContainer/VBoxContainer/CharacterCards/AdamsCard/AdamsContent/SelectButton
	var franklin_button = $ScrollContainer/VBoxContainer/CharacterCards/FranklinCard/FranklinContent/SelectButton
	var matlack_button = $ScrollContainer/VBoxContainer/CharacterCards/MatlackCard/MatlackContent/SelectButton
	
	jefferson_button.pressed.connect(_on_character_selected.bind("jefferson"))
	adams_button.pressed.connect(_on_character_selected.bind("adams"))
	franklin_button.pressed.connect(_on_character_selected.bind("franklin"))
	matlack_button.pressed.connect(_on_character_selected.bind("matlack"))

func _on_character_selected(character_id: String):
	game_manager.select_character(character_id)
	var character_data = null
	
	for character in game_manager.available_characters:
		if character.id == character_id:
			character_data = character
			break
	
	if character_data and character_data.has("morning_scene"):
		get_tree().change_scene_to_file(character_data.morning_scene)
	else:
		# Fallback to generic morning scene
		get_tree().change_scene_to_file("res://scenes/morning/MorningRoutine.tscn")