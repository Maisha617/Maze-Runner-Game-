# Author: Bianca Butler bb3424
extends Node3D

@onready var area = $Area3D

func _ready():
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "player":
		GameState.has_revive = true
		_show_ui_icon()
		queue_free()

func _show_ui_icon():
	var ui = get_tree().get_first_node_in_group("ui")
	if ui:
		ui.show_powerup_icon()
