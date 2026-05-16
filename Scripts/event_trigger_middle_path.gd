extends Area3D

@export var monster_scene: PackedScene
@export var flappy_scene: String
@export var tictactoe_scene: String
@export var memorygame_scene: String

var activated = false


func _ready():
	body_entered.connect(_on_trigger_entered)


func _on_trigger_entered(body: Node3D) -> void:
	if activated:
		return

	if not body.is_in_group("player"):
		return

	activated = true
	$CollisionShape3D.call_deferred("set_disabled", true)
	$"../EventTriggerMiddlePath/OneWayWallMiddle/CollisionShape3D".call_deferred("set_disabled", false)

	var choice := randi() % 4

	match choice:
		0:
			get_tree().change_scene_to_file(flappy_scene)

		1:
			get_tree().change_scene_to_file(tictactoe_scene)

		2:
			get_tree().change_scene_to_file(memorygame_scene)
			
		3:
			_spawn_monster()


func _spawn_monster():
	var monster := monster_scene.instantiate()
	monster.global_transform = $MonsterSpawn.global_transform
	get_parent().add_child(monster)

	if monster.has_method("start_running"):
		monster.start_running()


func _on_body_entered(body: Node3D) -> void:
	pass # Replace with function body.
