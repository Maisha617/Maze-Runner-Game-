extends CanvasLayer

func _input(event):
	if get_tree().paused:
		if event.is_action_pressed("jump") or event is InputEventMouseButton:
			get_tree().paused = false
			get_tree().reload_current_scene()
