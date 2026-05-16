extends Node3D

var sens = 0.005

# --- HEAD BOB VARIABLES ---
var bob_amount = 0.05
var bob_speed = 14.0
var bob_time = 0.0
var default_y = 0.0
var player = null
# --------------------------


func _ready():

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	player = get_parent()  # parent is the Player (CharacterBody3D)
	default_y = transform.origin.y

# This funciton runs everytime the player gives an input.
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Rotates the player left or right based on horizontal mouse movement.
		player.rotate_y(-event.relative.x * sens)

		# Rotates the camera holder up or down based on the veritcal mouse movement.
		rotate_x(-event.relative.y * sens)
		# This limits the veritcal camera rotation, so the camera doesnt flip upside down.
		rotation.x = clamp(rotation.x, deg_to_rad(-25), deg_to_rad(90))
# When the esc key is pressed,the mouse cursor will become visible.
	if event.is_action_pressed("esc"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var is_moving = input_dir.length() > 0.1

	var t = transform

	if is_moving:
		bob_time += delta * bob_speed

		# Vertical bob
		t.origin.y = default_y + sin(bob_time * 1.0) * bob_amount

		# Horizontal sway (makes bobbing more obvious)
		t.origin.x = sin(bob_time * 0.5 + PI/2) * (bob_amount * 1.5)
	else:
		t.origin.y = lerp(t.origin.y, default_y, delta * 10)
		t.origin.x = lerp(t.origin.x, 0.0, delta * 10)
		
	transform = t
