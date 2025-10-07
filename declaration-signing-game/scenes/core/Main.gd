extends Control

@onready var main_menu = $MainMenu
@onready var settings_menu = $SettingsMenu
@onready var game_manager = $GameManager

@onready var start_button = $MainMenu/StartButton
@onready var settings_button = $MainMenu/SettingsButton
@onready var credits_button = $MainMenu/CreditsButton
@onready var exit_button = $MainMenu/ExitButton

@onready var back_button = $SettingsMenu/BackButton
@onready var sdfgi_toggle = $SettingsMenu/SDFGIToggle
@onready var ssao_toggle = $SettingsMenu/SSAOToggle
@onready var msaa_option = $SettingsMenu/MSAAOption
@onready var subtitles_toggle = $SettingsMenu/SubtitlesToggle

func _ready():
	setup_ui()
	setup_settings()

func setup_ui():
	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	credits_button.pressed.connect(_on_credits_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	sdfgi_toggle.toggled.connect(_on_sdfgi_toggled)
	ssao_toggle.toggled.connect(_on_ssao_toggled)
	msaa_option.item_selected.connect(_on_msaa_selected)

func setup_settings():
	msaa_option.add_item("Disabled")
	msaa_option.add_item("2x MSAA")
	msaa_option.add_item("4x MSAA")
	msaa_option.add_item("8x MSAA")
	msaa_option.selected = 1  # Default to 2x MSAA

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/core/CharacterSelect.tscn")

func _on_settings_pressed():
	main_menu.visible = false
	settings_menu.visible = true

func _on_credits_pressed():
	get_tree().change_scene_to_file("res://scenes/core/Credits.tscn")

func _on_exit_pressed():
	get_tree().quit()

func _on_back_pressed():
	settings_menu.visible = false
	main_menu.visible = true

func _on_sdfgi_toggled(button_pressed: bool):
	var environment = RenderingServer.get_rendering_device()
	# Note: SDFGI settings would be applied to the current environment
	# This is a placeholder for the actual implementation

func _on_ssao_toggled(button_pressed: bool):
	# Apply SSAO setting to current environment
	pass

func _on_msaa_selected(index: int):
	var msaa_values = [
		RenderingServer.VIEWPORT_MSAA_DISABLED,
		RenderingServer.VIEWPORT_MSAA_2X,
		RenderingServer.VIEWPORT_MSAA_4X,
		RenderingServer.VIEWPORT_MSAA_8X
	]
	if index < msaa_values.size():
		get_viewport().msaa_3d = msaa_values[index]