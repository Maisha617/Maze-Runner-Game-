extends Node3D

@export var powerup_scene: PackedScene
@onready var points = get_children()

func _ready():
	spawn_powerup()

func spawn_powerup():
	if points.is_empty() or powerup_scene == null:
		return

	var point = points.pick_random()
	var powerup = powerup_scene.instantiate()
	powerup.global_transform = point.global_transform
	get_parent().call_deferred("add_child", powerup)
