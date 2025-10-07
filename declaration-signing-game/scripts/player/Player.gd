extends CharacterBody3D

@export var speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.001
@export var bob_frequency: float = 2.0
@export var bob_amplitude: float = 0.08

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_sprinting: bool = false
var current_speed: float
var bob_vector: Vector2
var time: float = 0.0

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var interact_raycast = $Head/Camera3D/InteractRaycast
@onready var interaction_prompt = $UI/InteractionPrompt
@onready var source_overlay = $UI/SourceOverlay
@onready var source_content = $UI/SourceOverlay/SourceContent/SourceList
@onready var journal = $UI/Journal
@onready var journal_content = $UI/Journal/JournalContent/JournalText
@onready var legend_indicator = $UI/LegendIndicator

var game_manager: GameManager
var current_interactable: Interactable

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	game_manager = GameManager.new()
	game_manager.scene_changed.connect(_on_scene_changed)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _input(event):
	if Input.is_action_just_pressed("interact") and current_interactable:
		current_interactable.interact()
		
	if Input.is_action_just_pressed("sources"):
		source_overlay.visible = !source_overlay.visible
		game_manager.toggle_sources()
		
	if Input.is_action_just_pressed("journal"):
		journal.visible = !journal.visible
		if journal.visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
	if Input.is_action_just_pressed("legend_toggle"):
		game_manager.toggle_legend_mode()
		update_legend_indicator()

func _physics_process(delta):
	handle_movement(delta)
	handle_headbob(delta)
	check_interactions()

func handle_movement(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	is_sprinting = Input.is_action_pressed("sprint")
	current_speed = sprint_speed if is_sprinting else speed

	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()

func handle_headbob(delta):
	time += delta * velocity.length() * float(is_on_floor())
	if velocity.length() > 0.5:
		bob_vector.y = sin(time * bob_frequency) * bob_amplitude
		bob_vector.x = cos(time * bob_frequency / 2) * bob_amplitude
	else:
		bob_vector = Vector2.ZERO

	camera.transform.origin = Vector3(bob_vector.x, bob_vector.y, 0)

func check_interactions():
	if interact_raycast.is_colliding():
		var collider = interact_raycast.get_collider()
		var interactable = collider.get_node("Interactable") if collider.has_node("Interactable") else null
		
		if interactable and interactable is Interactable:
			current_interactable = interactable
			interaction_prompt.text = interactable.prompt_text
			interaction_prompt.visible = true
		else:
			current_interactable = null
			interaction_prompt.visible = false
	else:
		current_interactable = null
		interaction_prompt.visible = false

func update_legend_indicator():
	var mode_text = "ON" if game_manager.game_state.legend_mode else "OFF"
	legend_indicator.text = "[L] Legend Mode: " + mode_text

func _on_scene_changed(scene_name: String):
	update_journal_for_scene(scene_name)
	update_sources_for_scene(scene_name)

func update_journal_for_scene(scene_name: String):
	var journal_entries = {
		"character_select": "Choose your perspective on this historic day...",
		"morning_routine": "Begin your morning routine. Prepare for the momentous day ahead.",
		"philly_streets": "Make your way through Philadelphia's streets to the State House.",
		"assembly_room": "Witness the formal signing of the engrossed Declaration of Independence.",
		"reading": "Experience the first public reading of the Declaration to the people.",
		"epilogue": "The Declaration reaches New York and Washington's Continental Army."
	}
	
	if journal_entries.has(scene_name):
		journal_content.text = journal_entries[scene_name]

func update_sources_for_scene(scene_name: String):
	# This will be populated with actual source data
	source_content.text = "Loading sources for current scene..."