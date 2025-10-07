extends Node3D

var game_manager: GameManager
var morning_tasks_completed: int = 0
var required_tasks: int = 3

@onready var player = $Player
@onready var bed_interactable = $Bed/BedInteractable
@onready var desk_interactable = $Desk/DeskInteractable  
@onready var thermometer_interactable = $Thermometer/ThermometerInteractable
@onready var washbasin_interactable = $Washbasin/WashbasinInteractable
@onready var door_interactable = $ExitDoor/DoorInteractable

func _ready():
	game_manager = GameManager.new()
	setup_interactables()
	update_journal()

func setup_interactables():
	bed_interactable.prompt_text = "Press E to make bed"
	bed_interactable.source_id = "graff_house_furnishing"
	bed_interactable.interacted.connect(_on_bed_interacted)
	
	desk_interactable.prompt_text = "Press E to review Declaration draft"
	desk_interactable.source_id = "jefferson_draft_revisions" 
	desk_interactable.interacted.connect(_on_desk_interacted)
	
	thermometer_interactable.prompt_text = "Press E to check thermometer"
	thermometer_interactable.source_id = "jefferson_weather_observations"
	thermometer_interactable.interacted.connect(_on_thermometer_interacted)
	
	washbasin_interactable.prompt_text = "Press E to wash"
	washbasin_interactable.source_id = "colonial_morning_routine"
	washbasin_interactable.interacted.connect(_on_washbasin_interacted)
	
	door_interactable.prompt_text = "Press E to leave for State House"
	door_interactable.source_id = "graff_house_location"
	door_interactable.interacted.connect(_on_door_interacted)

func _on_bed_interacted(interactable):
	if not interactable.has_meta("completed"):
		morning_tasks_completed += 1
		interactable.set_meta("completed", true)
		interactable.prompt_text = "Bed made"
		show_task_complete_message("Bed made neat and tidy.")
		check_morning_completion()

func _on_desk_interacted(interactable):
	if not interactable.has_meta("completed"):
		morning_tasks_completed += 1
		interactable.set_meta("completed", true)
		interactable.prompt_text = "Draft reviewed"
		show_task_complete_message("Reviewed the Declaration draft one final time.")
		check_morning_completion()

func _on_thermometer_interacted(interactable):
	if not interactable.has_meta("completed"):
		morning_tasks_completed += 1
		interactable.set_meta("completed", true)
		interactable.prompt_text = "Temperature noted: 68°F"
		show_task_complete_message("A pleasant 68 degrees - a good day for history. [jefferson_weather_jul1776]")
		check_morning_completion()

func _on_washbasin_interacted(interactable):
	if not interactable.has_meta("completed"):
		morning_tasks_completed += 1
		interactable.set_meta("completed", true)
		interactable.prompt_text = "Morning washing complete"
		show_task_complete_message("Refreshed and ready for the momentous day.")
		check_morning_completion()

func _on_door_interacted(interactable):
	if morning_tasks_completed >= required_tasks:
		game_manager.complete_morning_routine()
	else:
		show_task_complete_message("Complete your morning routine first. Tasks remaining: " + str(required_tasks - morning_tasks_completed))

func check_morning_completion():
	if morning_tasks_completed >= required_tasks:
		update_journal()
		door_interactable.prompt_text = "Press E to leave for State House (Morning routine complete)"

func show_task_complete_message(message: String):
	# Create a temporary label to show the message
	var temp_label = Label.new()
	temp_label.text = message
	temp_label.position = Vector2(50, 50)
	temp_label.modulate = Color.YELLOW
	player.get_node("UI").add_child(temp_label)
	
	# Remove after 3 seconds
	var timer = Timer.new()
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.timeout.connect(func(): 
		if temp_label and is_instance_valid(temp_label):
			temp_label.queue_free()
		timer.queue_free()
	)
	add_child(timer)
	timer.start()

func update_journal():
	var journal_text = """THOMAS JEFFERSON - Morning of August 2nd, 1776
Graff House, 700 Market Street (High Street)

Today we formalize our break from Britain. The document I drafted in this very room will receive the delegates' signatures on the engrossed parchment Matlack has prepared.

Tasks completed: %d/%d
- Make bed
- Review Declaration draft  
- Check thermometer (noted clear, pleasant morning)
- Morning washing

Once ready, proceed to the State House Assembly Room for the signing ceremony.

[Source: NPS Declaration House interpretation]""" % [morning_tasks_completed, required_tasks]

	if player.has_method("update_journal_content"):
		player.update_journal_content(journal_text)