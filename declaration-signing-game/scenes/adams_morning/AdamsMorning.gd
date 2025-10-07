extends Node3D

var game_manager: GameManager
var morning_tasks_completed: int = 0
var required_tasks: int = 3

@onready var player = $Player
@onready var bed_interactable = $Bed/BedInteractable
@onready var table_interactable = $WritingTable/TableInteractable
@onready var correspondence_interactable = $CorrespondenceDesk/CorrespondenceInteractable
@onready var washstand_interactable = $Washstand/WashstandInteractable
@onready var door_interactable = $ExitDoor/DoorInteractable

func _ready():
	game_manager = GameManager.new()
	setup_interactables()
	update_journal()

func setup_interactables():
	bed_interactable.prompt_text = "Press E to make bed"
	bed_interactable.source_id = "adams_boarding_house"
	bed_interactable.interacted.connect(_on_bed_interacted)
	
	table_interactable.prompt_text = "Press E to organize papers"
	table_interactable.source_id = "adams_congressional_papers"
	table_interactable.interacted.connect(_on_table_interacted)
	
	correspondence_interactable.prompt_text = "Press E to read letter from Abigail"
	correspondence_interactable.source_id = "adams_abigail_correspondence"
	correspondence_interactable.interacted.connect(_on_correspondence_interacted)
	
	washstand_interactable.prompt_text = "Press E to wash and dress"
	washstand_interactable.source_id = "colonial_morning_routine"
	washstand_interactable.interacted.connect(_on_washstand_interacted)
	
	door_interactable.prompt_text = "Press E to depart for State House"
	door_interactable.source_id = "yard_boarding_house_location"
	door_interactable.interacted.connect(_on_door_interacted)

func _on_bed_interacted(interactable):
	if not interactable.has_meta("completed"):
		morning_tasks_completed += 1
		interactable.set_meta("completed", true)
		interactable.prompt_text = "Bed tidied"
		show_task_complete_message("Bed made with New England efficiency.")
		check_morning_completion()

func _on_table_interacted(interactable):
	if not interactable.has_meta("completed"):
		morning_tasks_completed += 1
		interactable.set_meta("completed", true)
		interactable.prompt_text = "Papers organized"
		show_task_complete_message("Congressional notes and drafts organized for today's business.")
		check_morning_completion()

func _on_correspondence_interacted(interactable):
	if not interactable.has_meta("completed"):
		morning_tasks_completed += 1
		interactable.set_meta("completed", true)
		interactable.prompt_text = "Letter read"
		show_task_complete_message("'Remember the ladies' - Abigail's wisdom guides me even here. [adams_abigail_letters]")
		check_morning_completion()

func _on_washstand_interacted(interactable):
	if not interactable.has_meta("completed"):
		morning_tasks_completed += 1
		interactable.set_meta("completed", true)
		interactable.prompt_text = "Morning ablutions complete"
		show_task_complete_message("Properly attired for this historic day.")
		check_morning_completion()

func _on_door_interacted(interactable):
	if morning_tasks_completed >= required_tasks:
		game_manager.complete_morning_routine()
	else:
		show_task_complete_message("Complete morning preparations first. Tasks remaining: " + str(required_tasks - morning_tasks_completed))

func check_morning_completion():
	if morning_tasks_completed >= required_tasks:
		update_journal()
		door_interactable.prompt_text = "Press E to depart for State House (Ready to go)"

func show_task_complete_message(message: String):
	var temp_label = Label.new()
	temp_label.text = message
	temp_label.position = Vector2(50, 50)
	temp_label.modulate = Color.CYAN
	player.get_node("UI").add_child(temp_label)
	
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
	var journal_text = """JOHN ADAMS - Morning of August 2nd, 1776
Mrs. Sarah Yard's Boarding House, Second Street

I have long advocated for this break from British tyranny. Today we make it formal and legal with our signatures on the engrossed parchment.

Tasks completed: %d/%d
- Tidy boarding room bed
- Organize congressional papers
- Read correspondence from Abigail
- Morning washing and dressing

The Massachusetts delegation stands ready. To the State House!

[Source: Founders Archives - Adams Papers]""" % [morning_tasks_completed, required_tasks]

	if player.has_method("update_journal_content"):
		player.update_journal_content(journal_text)