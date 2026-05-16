extends Node2D
#Author: Ashvi Jain
# Variables
var previous_level := ""
var x: float = 0.0
var y: float = 0.0
var speed_y: float = 0.0
var gravity: float = 0.4  
var jump_force: float = -8.0
var circle_radius: float = 15.0 
var score: int = 0
var font_size: int = 24
var game_started := false
var obstacles := [] 
var game_won := false
var spawn_timer: float = 0.0
var spawn_interval: float = 1.5
var pipe_width: float = 60.0
var gap_height: float = 160.0
var pipe_speed: float = 200.0
var screen_size := Vector2()

var game_over := false
var revive_pending := false # Author: Bianca Butler bb3424 line 24


func _ready():
	# Author: Bianca Butler bb3424 lines 28-33
	#Reset revive_pending on new level
	add_to_group("flappy")
	game_over = false
	revive_pending = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# Fix: Use the global variable, don't create a local one with 'var'
	screen_size = get_viewport_rect().size
	x = screen_size.x / 7
	y = screen_size.y / 2
	speed_y = 0.0
	randomize()

func _process(delta):
	# Author: Bianca Butler bb3424 lines 43-45
	# LOCK GAME LOGIC WHILE REVIVE POPUP IS OPEN
	if revive_pending:
		queue_redraw()
		return

	if not game_started or game_over:
		queue_redraw()
		return
	# Apply Gravity
	speed_y += gravity
	y += speed_y
	
	# Spawn pipes
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		_spawn_pipe()
		spawn_timer = 0.0
		
	# Move pipes
	for i in range(obstacles.size() - 1, -1, -1):
		var p = obstacles[i]
		# Rect2 is a primitive, so we have to recreate it to modify it
		p.top.position.x -= pipe_speed * delta
		p.bottom.position.x -= pipe_speed * delta
		# POINT TRACKING: If bird x is past pipe x and pipe hasn't scored yet
		if not p.scored and x > p.top.position.x + pipe_width:
			score += 1
			p.scored = true
			if score >= 10:
				game_won = true
				$Game_Win_Sound.play()
			print("Score: ", score)
		
		if p.top.position.x + p.top.size.x < -100:
			obstacles.remove_at(i)
	# Consolidated Collision & Boundary Check
	if _check_collision() or y > screen_size.y or y < 0:
		
		# Author: Bianca Butler bb3424 lines 72-78
		# REVIVE CHECK FIRST
		if GameState.has_revive and not game_over:
			game_over = true
			revive_pending = true
			show_revive_popup()
			return  # stop game-over logic

		trigger_game_over()
	queue_redraw()

func _input(event):
	# Author: Bianca Butler bb3424 lines 94-96
	# BLOCK ALL INPUT WHILE REVIVE POPUP IS ACTIVE
	if revive_pending:
		return

	# Case 1: Game Over (User lost before 10 points)
	if game_over and event.is_pressed():
		get_tree().change_scene_to_file(GameState.current_level)
		return
	# Case 2: Game Won (User reached 10 points)
	if game_won and event.is_pressed():
		if GameState.current_level == "res://Scenes/Environment.tscn":
			get_tree().change_scene_to_file("res://Scenes/SecondLevel.tscn")
		elif GameState.current_level == "res://Scenes/SecondLevel.tscn":
			get_tree().change_scene_to_file("res://Scenes/ThirdLevel.tscn")
		elif GameState.current_level == ("res://Scenes/ThirdLevel.tscn"):
			get_tree().change_scene_to_file("res://Scenes/FourthLevel.tscn")
		elif GameState.current_level == ("res://Scenes/FourthLevel.tscn"):
			get_tree().change_scene_to_file("res://Scenes/FifthLevel.tscn")
		return
	if not game_started:
		if (event is InputEventMouseButton and event.pressed) or (event.is_action_pressed("ui_select")):
			game_started = true
			return
	if event is InputEventMouseButton and not game_over:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			$Click_Sound.play()
			speed_y = jump_force
	if event.is_action_pressed("ui_select") and not game_over:
		$Click_Sound.play()
		speed_y = jump_force
		
func _draw():
	var default_font = Control.new().get_theme_default_font()
	if not game_started:
		draw_string(default_font, Vector2(screen_size.x/2 - 180, screen_size.y/2 - 60), "FLAPPY BIRD GAME", HORIZONTAL_ALIGNMENT_CENTER, -1, 48)
		draw_string(default_font, Vector2(screen_size.x/2 - 180, screen_size.y/2 + 50), "Score 10 points To Win!", HORIZONTAL_ALIGNMENT_CENTER, -1, 42)
		# Draw the ball in a preview position
		draw_circle(Vector2(x, y), circle_radius, Color.OLD_LACE)
		return # Stop drawing the rest of the game until we start
	# Draw ball
	draw_circle(Vector2(x, y), circle_radius, Color.OLD_LACE)
	# Draw pipes
	for p in obstacles:
		# Fix: Use the actual Rect2 objects stored in the dictionary
		draw_rect(p.top, Color.DARK_OLIVE_GREEN)
		draw_rect(p.bottom, Color.DARK_OLIVE_GREEN)
	default_font = Control.new().get_theme_default_font()
	# Draw Live Score (Top Right)
	var score_text = "Score: " + str(score)
	draw_string(default_font, Vector2(screen_size.x - 220, 100), score_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 48)
	# Draw Game Over Text
	if game_over:
		# Create a temporary reference to the default font
		default_font = Control.new().get_theme_default_font()
		# Draw the strings using that font
		draw_string(default_font, Vector2(screen_size.x/2 - 50, screen_size.y/2), "YOU LOSE", HORIZONTAL_ALIGNMENT_CENTER, -1, 50)
	if game_won:
		default_font = Control.new().get_theme_default_font()
		draw_string(default_font, Vector2(screen_size.x/2 - 100, screen_size.y/2), "YOU WIN!", HORIZONTAL_ALIGNMENT_CENTER, -1, 50)
		return
		

func _spawn_pipe():
	
	var min_gap_y = 50.0
	var max_gap_y = screen_size.y - 50.0 - gap_height
	var gap_y = randf_range(min_gap_y, max_gap_y)
	
	var start_x = screen_size.x + 20
	
	var top_rect = Rect2(Vector2(start_x, 0), Vector2(pipe_width, gap_y))
	var bottom_rect = Rect2(Vector2(start_x, gap_y + gap_height), Vector2(pipe_width, screen_size.y))
	obstacles.append({"top": top_rect, "bottom": bottom_rect, "scored": false})

func _check_collision() -> bool:
	for p in obstacles:
		if _circle_rect_overlap(x, y, circle_radius, p.top):
			return true
		if _circle_rect_overlap(x, y, circle_radius, p.bottom):
			return true
	return false

func _circle_rect_overlap(cx: float, cy: float, r: float, rect: Rect2) -> bool:
	var closest_x = clamp(cx, rect.position.x, rect.position.x + rect.size.x)
	var closest_y = clamp(cy, rect.position.y, rect.position.y + rect.size.y)
	var dx = cx - closest_x
	var dy = cy - closest_y
	return (dx * dx + dy * dy) <= r * r

func trigger_game_over():
	game_over = true
	$Game_Over_Sound.play()
	print("Game Over!")
	
# Author: Bianca Butler bb3424 lines 172-181
func show_revive_popup():
	var ui = get_tree().get_first_node_in_group("ui")
	ui.show_revive_popup()
	revive_pending = true

func hide_revive_popup():
	var ui = get_tree().get_first_node_in_group("ui")
	if ui:
		ui.hide_revive_popup()
	revive_pending = false
