# Author: Bianca Butler bb3424
extends CharacterBody3D

@onready var anim = $AnimationPlayer
@onready var crawling_sound = $CrawlingSound
@onready var bite_sound = $BiteSound

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var stopped = false
var attacking = false

func _ready():
	anim.play("run")
	
	# Starts crawling sound when monster begins moving
	if not crawling_sound.playing:
		crawling_sound.play()

func _physics_process(delta):
	# Stops crawling sound if monster stops or attacks
	if stopped or attacking:
		if crawling_sound.playing:
			crawling_sound.stop()
		velocity = Vector3.ZERO
		move_and_slide()
		return
		
	# Ensures crawling sound is always playing while moving
	if not crawling_sound.playing:
		crawling_sound.play()
		
	velocity.y -= gravity * delta

	var forward = -transform.basis.x
	forward.y = 0
	forward = forward.normalized()

	velocity = forward * 12.0
	move_and_slide()


# ---------------------------------------------------------
# PLAYER DEATH HANDLING
# ---------------------------------------------------------

func _kill_player(player):
	# Freeze the game world
	get_tree().paused = true

	# Play the YOU DIED animation
	var ui = get_tree().get_current_scene().get_node("CanvasLayer")
	var death_anim = ui.get_node("DeathEffect")

	death_anim.play("Death_Effect")

	# DO NOT teleport the player
	# DO NOT reload the scene here
	# Wait for player input to restart


# ---------------------------------------------------------
# ATTACK LOGIC
# ---------------------------------------------------------

func _on_attack_range_body_entered(body):
	if body.is_in_group("player") and not attacking:
		attacking = true
		anim.play("jump")
		
		crawling_sound.stop()
		anim.play("jump")
		# Play bite sound immediately when jump begins
		bite_sound.play()
		
		# When animation finishes, kill the player
		anim.connect("animation_finished", Callable(self, "_on_attack_finished").bind(body))


func _on_attack_finished(anim_name, player):
	if anim_name == "jump":
		_kill_player(player)
		stopped = true


# ---------------------------------------------------------
# RESTART GAME
# ---------------------------------------------------------

func restart_game():
	get_tree().paused = false
	get_tree().reload_current_scene()
