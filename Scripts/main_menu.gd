extends Control

func _ready() -> void:
	$ColorRect.color = Color.BLACK
	$ColorRect.modulate = Color(1, 1, 1, 0)

func _on_button_pressed() -> void:
	var tween = create_tween()
	tween.tween_property($ColorRect, "modulate:a", 1.0, 1.0)
	await tween.finished
	_go_to_game()

func _go_to_game():
	get_tree().change_scene_to_file("res://Scenes/Environment.tscn")


func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/About_Us.tscn")
	
	
	
