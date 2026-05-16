extends Node3D

@export var level_path: String

func _ready() -> void:
	GameState.current_level = level_path
	
	#Lines 6-12 Author: Janiyah Lizzimore jal547
	$CanvasLayer/ColorRect.color = Color.BLACK
	$CanvasLayer/ColorRect.modulate.a = 1.0

	var tween = create_tween()
	tween.tween_property($CanvasLayer/ColorRect, "modulate:a", 0.0, 1.0)
	await tween.finished
	$CanvasLayer/ColorRect.hide()
	
	#Lines 15-21 Author: Maisha Rahman mr3798
	
	# Delay respawn by ONE frame so Player exists
	await get_tree().process_frame
	
	var spawn = $SpawnPoint
	var player = get_node("player")
	
	player.global_transform = spawn.global_transform
