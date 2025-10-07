extends Node3D

var game_manager: GameManager

@onready var player = $Player
@onready var market_sign = $MarketStreet/MarketStreetSign/SignInteractable
@onready var graff_house = $MarketStreet/GraffHouse/GraffHouseInteractable
@onready var chestnut_sign = $ChestnutStreet/ChestnutSign/SignInteractable
@onready var state_house_entrance = $ChestnutStreet/StateHouse/StateHouseEntrance
@onready var yard_area = $ChestnutStreet/StateHouseYard/YardArea/YardInteractable
@onready var second_sign = $SecondStreet/SecondStreetSign/SignInteractable
@onready var boarding_house = $SecondStreet/YardBoardingHouse/BoardingHouseInteractable
@onready var franklin_court = $FranklinCourt/FranklinCourtBuilding/FranklinCourtInteractable

func _ready():
	game_manager = GameManager.new()
	setup_street_interactables()
	setup_navigation()
	update_journal()

func setup_street_interactables():
	# Street signs
	market_sign.prompt_text = "Market Street (also called High Street)"
	market_sign.source_id = "philly_1776_street_names"
	market_sign.interacted.connect(_on_street_sign_interacted.bind("market"))
	
	chestnut_sign.prompt_text = "Chestnut Street - Location of the State House"
	chestnut_sign.source_id = "state_house_address"
	chestnut_sign.interacted.connect(_on_street_sign_interacted.bind("chestnut"))
	
	second_sign.prompt_text = "Second Street"
	second_sign.source_id = "philly_1776_street_grid"
	second_sign.interacted.connect(_on_street_sign_interacted.bind("second"))
	
	# Historical buildings
	graff_house.prompt_text = "Graff House - Declaration House (700 Market St.)"
	graff_house.source_id = "nps_declaration_house"
	graff_house.interacted.connect(_on_building_interacted.bind("graff"))
	
	boarding_house.prompt_text = "Mrs. Sarah Yard's Boarding House"
	boarding_house.source_id = "adams_boarding_location"
	boarding_house.interacted.connect(_on_building_interacted.bind("boarding"))
	
	franklin_court.prompt_text = "Franklin Court (322 Market Street)"
	franklin_court.source_id = "nps_franklin_court"
	franklin_court.interacted.connect(_on_building_interacted.bind("franklin"))
	
	# State House
	state_house_entrance.prompt_text = "Press E to enter State House Assembly Room"
	state_house_entrance.source_id = "nps_independence_hall"
	state_house_entrance.interacted.connect(_on_state_house_entered)
	
	yard_area.prompt_text = "State House Yard - Site of July 8th public reading"
	yard_area.source_id = "first_public_reading_jul8"
	yard_area.interacted.connect(_on_yard_interacted)

func setup_navigation():
	# Navigation mesh would be baked here in a real implementation
	pass

func _on_street_sign_interacted(street_name: String):
	var messages = {
		"market": "Market Street, also known as High Street. Major east-west thoroughfare in 1776 Philadelphia. [philly_maps_1752_1776]",
		"chestnut": "Chestnut Street - Home to the Pennsylvania State House where the Continental Congress meets. [state_house_location]", 
		"second": "Second Street - North-south street. Location of various boarding houses for Congressional delegates. [philly_street_grid_1776]"
	}
	show_street_message(messages.get(street_name, "Historical street marker"))

func _on_building_interacted(building_name: String):
	var messages = {
		"graff": "Jacob Graff Jr.'s house where Jefferson lodged and wrote the Declaration draft. Now called Declaration House. [nps_declaration_house]",
		"boarding": "Mrs. Sarah Yard's boarding house on Second Street. John Adams stayed here during Congressional sessions. [founders_archives_adams]",
		"franklin": "Benjamin Franklin's Philadelphia residence and print shop. Franklin Court complex. [nps_franklin_court]"
	}
	show_street_message(messages.get(building_name, "Historical building"))

func _on_state_house_entered():
	show_street_message("Entering the Pennsylvania State House Assembly Room for the signing ceremony...")
	# Transition to Assembly Room after brief delay
	var timer = Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true
	timer.timeout.connect(func(): 
		game_manager.arrive_at_state_house()
		timer.queue_free()
	)
	add_child(timer)
	timer.start()

func _on_yard_interacted():
	show_street_message("This is where John Nixon read the Declaration aloud to the public on July 8, 1776. Some legends say the Liberty Bell rang, but no contemporary accounts confirm this. [first_public_reading_sources]")
	
	# Offer flashback option
	var timer = Timer.new()
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.timeout.connect(func():
		show_flashback_prompt()
		timer.queue_free()
	)
	add_child(timer)
	timer.start()

func show_flashback_prompt():
	var prompt_label = Label.new()
	prompt_label.text = "Press F to experience July 8th public reading flashback"
	prompt_label.position = Vector2(50, 100)
	prompt_label.modulate = Color.YELLOW
	player.get_node("UI").add_child(prompt_label)
	
	# Listen for F key
	var input_timer = Timer.new()
	input_timer.wait_time = 0.1
	input_timer.timeout.connect(func():
		if Input.is_action_just_pressed("ui_select"): # F key
			game_manager.trigger_flashback()
			prompt_label.queue_free()
			input_timer.queue_free()
	)
	add_child(input_timer)
	input_timer.start()
	
	# Auto-remove prompt after 10 seconds
	var cleanup_timer = Timer.new()
	cleanup_timer.wait_time = 10.0
	cleanup_timer.one_shot = true
	cleanup_timer.timeout.connect(func():
		if is_instance_valid(prompt_label):
			prompt_label.queue_free()
		if is_instance_valid(input_timer):
			input_timer.queue_free()
		cleanup_timer.queue_free()
	)
	add_child(cleanup_timer)
	cleanup_timer.start()

func show_street_message(message: String):
	var temp_label = Label.new()
	temp_label.text = message
	temp_label.position = Vector2(50, 50)
	temp_label.modulate = Color.WHITE
	temp_label.add_theme_color_override("font_color", Color.WHITE)
	temp_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	temp_label.add_theme_constant_override("shadow_offset_x", 1)
	temp_label.add_theme_constant_override("shadow_offset_y", 1)
	player.get_node("UI").add_child(temp_label)
	
	var timer = Timer.new()
	timer.wait_time = 4.0
	timer.one_shot = true
	timer.timeout.connect(func(): 
		if temp_label and is_instance_valid(temp_label):
			temp_label.queue_free()
		timer.queue_free()
	)
	add_child(timer)
	timer.start()

func update_journal():
	var journal_text = """PHILADELPHIA STREETS - August 2nd, 1776

Navigate the cobblestone streets of Philadelphia to reach the Pennsylvania State House on Chestnut Street.

STREET NAMES (1776):
• Market Street (also called High Street)
• Chestnut Street (location of State House)
• Second Street
• Fifth and Sixth Streets

NOTABLE LOCATIONS:
• Declaration House - 700 Market St. (Jefferson's lodging)
• Franklin Court - 322 Market St. (Franklin's residence)  
• Mrs. Yard's Boarding House - Second St. (Adams' lodging)
• State House Yard - Site of July 8th public reading

Destination: State House Assembly Room for the signing ceremony.

[Sources: LoC Philadelphia maps 1752-1777, NPS Independence Hall]"""

	if player.has_method("update_journal_content"):
		player.update_journal_content(journal_text)