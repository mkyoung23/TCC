extends Area3D
class_name Interactable

@export var prompt_text: String = "Press E to interact"
@export var source_id: String = ""
@export var legend_only: bool = false

signal interacted(interactable: Interactable)

var game_manager: GameManager

func _ready():
	game_manager = GameManager.new()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Set collision layer for interaction detection
	collision_layer = 2

func interact():
	# Check if this is a legend-only item and legend mode is off
	if legend_only and not game_manager.game_state.legend_mode:
		return
	
	interacted.emit(self)
	_on_interact()

func _on_interact():
	# Override this method in specific interactable implementations
	pass

func _on_body_entered(body):
	if body.name == "Player":
		show_interaction_prompt()

func _on_body_exited(body):
	if body.name == "Player":
		hide_interaction_prompt()

func show_interaction_prompt():
	# The player will handle showing the prompt
	pass

func hide_interaction_prompt():
	# The player will handle hiding the prompt
	pass

func get_source_info() -> Dictionary:
	# This would be loaded from the SourceLog.json
	return {
		"id": source_id,
		"description": "Source information placeholder",
		"url": "https://example.com",
		"citation": "Example Citation"
	}