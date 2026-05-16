# Author: Bianca Butler bb3424
extends Control

@onready var powerup_icon = $PowerUpIcon

func _ready():
	# ALWAYS start with popup hidden when a new level loads
	$CanvasLayer/RevivePopup.visible = false

	# Show or hide the revive icon depending on revive availability
	if GameState.has_revive:
		show_powerup_icon()
	else:
		hide_powerup_icon()


func show_powerup_icon():
	powerup_icon.visible = true


func hide_powerup_icon():
	powerup_icon.visible = false


# -------------------------
# REVIVE POPUP CONTROL
# -------------------------
func show_revive_popup():
	$CanvasLayer/RevivePopup.visible = true


func hide_revive_popup():
	$CanvasLayer/RevivePopup.visible = false


# -------------------------
# YES BUTTON
# -------------------------
func _on_yes_button_pressed() -> void:

	# Consume revive
	GameState.has_revive = false
	var ui = get_tree().get_first_node_in_group("ui")
	if ui:
		ui.hide_powerup_icon()
	
		
	# MUST HIDE FIRST so it doesn't carry into next level
	hide_revive_popup()
	
	# Level progression
	if GameState.current_level == "res://Scenes/Environment.tscn":
		GameState.current_level = "res://Scenes/SecondLevel.tscn"
	elif GameState.current_level == "res://Scenes/SecondLevel.tscn":
		GameState.current_level = "res://Scenes/ThirdLevel.tscn"
	elif GameState.current_level == "res://Scenes/ThirdLevel.tscn":
		GameState.current_level = "res://Scenes/FourthLevel.tscn"
	elif GameState.current_level == "res://Scenes/FourthLevel.tscn":
		GameState.current_level = "res://Scenes/FifthLevel.tscn"

	get_tree().change_scene_to_file(GameState.current_level)


# -------------------------
# NO BUTTON
# -------------------------
func _on_no_button_pressed() -> void:
	# MUST HIDE FIRST so it doesn't carry into next level
	hide_revive_popup()

	# Restart current level
	get_tree().change_scene_to_file(GameState.current_level)
