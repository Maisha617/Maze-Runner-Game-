extends CharacterBody3D

const SPEED = 40
const JUMP_VELOCITY = 15
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var footstep_player = $FootstepPlayer
var current_surface := "grass"
var footstep_timer := 0.0
var footstep_interval := 0.65

# Author: Bianca Butler bb3424 lines 13-16
@onready var anim = $"AnimatedCharacter/AnimationPlayer" 

func _ready():
	anim.play("Idle")

func _physics_process(delta: float) -> void:
	
	footstep_timer -= delta

	if not is_on_floor():
		velocity += get_gravity() * 2.8 * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		


# Author lines 32-62: Maisha Rahman mr3798
	var is_moving = velocity.length() > 0.1
	var on_ground = is_on_floor()

	if is_moving and on_ground and footstep_timer <= 0:
		play_footstep()
		footstep_timer = footstep_interval
		
	# Author: Bianca Butler bb3424 lines 59-65
	if on_ground:
		if is_moving:
			anim.play("Running")
		else:
			anim.play("Idle")

	move_and_slide()

func play_footstep():
	if current_surface == "grass":
		footstep_player.stream = preload("res://Sounds/grass-step.wav")
	else:
		footstep_player.stream = preload("res://Sounds/stone-step.wav")

	# Adds slight pitch variation for realism
	footstep_player.pitch_scale = randf_range(1, 1.2)
	footstep_player.play()

	#Controls only the stone sound speed
	if current_surface == "stone":
		footstep_player.pitch_scale = randf_range(1.8, 2) 
	else:
		footstep_player.pitch_scale = randf_range(1, 1.2)

func _on_grass_area_body_entered(body: Node3D) -> void:
	if body == self or body.get_parent() == self:
		current_surface = "grass"

func _on_stone_area_body_entered(body: Node3D) -> void:
	if body == self or body.get_parent() == self:
		current_surface = "stone"
