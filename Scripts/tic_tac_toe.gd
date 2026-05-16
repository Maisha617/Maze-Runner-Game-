extends Node2D

var previous_level := ""

var current_player := "X"
var buttons = []
var game_over := false
var revive_pending := false

# Score tracking
var total_games := 0
var player_wins := 0
var computer_wins := 0
var draws := 0

# UI elements
@onready var player_score_label = $ScoreBoard/PlayerScoreLabel
@onready var computer_score_label = $ScoreBoard/ComputerScoreLabel
@onready var draw_score_label = $ScoreBoard/DrawScoreLabel
@onready var top_banner_label = $TopBannerLabel


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	buttons = [
		$GridContainer/Button,
		$GridContainer/Button2,
		$GridContainer/Button3,
		$GridContainer/Button4,
		$GridContainer/Button5,
		$GridContainer/Button6,
		$GridContainer/Button7,
		$GridContainer/Button8,
		$GridContainer/Button9
	]

	randomize()

	await get_tree().process_frame

	# -------------------------
	# CENTER GRID
	# -------------------------
	var viewport_size = get_viewport_rect().size
	var grid_size = $GridContainer.size
	$GridContainer.position = (viewport_size - grid_size) / 2

	$ResultLabel.text = ""

	update_scoreboard()

	# -------------------------
	# INTRO BANNER
	# -------------------------
	top_banner_label.text = "First to 5 wins!"
	await get_tree().create_timer(4).timeout
	top_banner_label.text = ""


# -------------------------
# PLAYER MOVE
# -------------------------
func make_move(button: Button) -> void:
	if game_over:
		return

	if button.text != "":
		return

	if current_player != "X":
		return

	button.text = "X"

	if check_winner("X"):
		end_game("player")
		return

	if check_draw():
		end_game("draw")
		return

	current_player = "O"

	await get_tree().create_timer(0.4).timeout
	computer_move()

func computer_move() -> void:

	# -------------------------
	# 1. Sometimes try to WIN
	# -------------------------
	if randi() % 100 < 75:

		for combo in get_win_combinations():

			var result = check_possible_move(combo, "O")

			if result != null:

				result.text = "O"

				if check_winner("O"):
					end_game("computer")
					return

				if check_draw():
					end_game("draw")
					return

				current_player = "X"
				return


	# -------------------------
	# 2. Sometimes BLOCK player
	# -------------------------
	if randi() % 100 < 60:

		for combo in get_win_combinations():

			var result = check_possible_move(combo, "X")

			if result != null:

				result.text = "O"

				if check_draw():
					end_game("draw")
					return

				current_player = "X"
				return


	# -------------------------
	# 3. Random move
	# -------------------------
	var empty_buttons = []

	for button in buttons:
		if button.text == "":
			empty_buttons.append(button)

	if empty_buttons.size() == 0:
		return

	var chosen_button = empty_buttons[randi() % empty_buttons.size()]
	chosen_button.text = "O"


	# -------------------------
	# CHECK RESULTS
	# -------------------------
	if check_winner("O"):
		end_game("computer")
		return

	if check_draw():
		end_game("draw")
		return

	current_player = "X"



# -------------------------
# WIN CHECK
# -------------------------
func check_winner(player: String) -> bool:
	for combo in get_win_combinations():

		if buttons[combo[0]].text == player \
		and buttons[combo[1]].text == player \
		and buttons[combo[2]].text == player:
			return true

	return false


# -------------------------
# WIN COMBINATIONS
# -------------------------
func get_win_combinations():
	return [
		[0,1,2],
		[3,4,5],
		[6,7,8],
		[0,3,6],
		[1,4,7],
		[2,5,8],
		[0,4,8],
		[2,4,6]
	]


# -------------------------
# SMART MOVE CHECK
# -------------------------
func check_possible_move(combo, player):

	var player_count = 0
	var empty_button = null

	for index in combo:

		if buttons[index].text == player:
			player_count += 1

		elif buttons[index].text == "":
			empty_button = buttons[index]

	if player_count == 2 and empty_button != null:
		return empty_button

	return null


# -------------------------
# DRAW CHECK
# -------------------------
func check_draw() -> bool:
	for button in buttons:
		if button.text == "":
			return false

	return true


# -------------------------
# END ROUND
# -------------------------
func end_game(result: String) -> void:

	game_over = true
	total_games += 1

	if result == "player":
		player_wins += 1
		$ResultLabel.text = "You Win!"

	elif result == "computer":
		computer_wins += 1
		$ResultLabel.text = "You Lose!"

	else:
		draws += 1
		$ResultLabel.text = "Draw!"

	update_scoreboard()

	await get_tree().create_timer(1.5).timeout

	# Check if someone reached 5 wins
	check_match_winner()

	# Continue match if nobody has 5 wins yet
	if player_wins < 5 and computer_wins < 5:
		reset_game()


# -------------------------
# MATCH WIN CHECK
# -------------------------
func check_match_winner():

	# PLAYER WINS MATCH
	if player_wins >= 5:

		$ResultLabel.text = "MATCH WON!"

		await get_tree().create_timer(2).timeout

		if GameState.current_level == "res://Scenes/Environment.tscn":
			get_tree().change_scene_to_file("res://Scenes/SecondLevel.tscn")

		elif GameState.current_level == "res://Scenes/SecondLevel.tscn":
			get_tree().change_scene_to_file("res://Scenes/ThirdLevel.tscn")
		elif GameState.current_level == ("res://Scenes/ThirdLevel.tscn"):
			get_tree().change_scene_to_file("res://Scenes/FourthLevel.tscn")
		elif GameState.current_level == ("res://Scenes/FourthLevel.tscn"):
			get_tree().change_scene_to_file("res://Scenes/FifthLevel.tscn")

	# COMPUTER WINS MATCH
	elif computer_wins >= 5:
		# Author: Bianca Butler bb3424 lines 288-291
		if GameState.has_revive:
				revive_pending = true
				show_revive_popup()
				return
				
		$ResultLabel.text = "MATCH LOST!"

		await get_tree().create_timer(2).timeout

		get_tree().change_scene_to_file(GameState.current_level)


# -------------------------
# RESET ROUND
# -------------------------
func reset_game() -> void:

	current_player = "X"
	game_over = false

	for button in buttons:
		button.text = ""

	$ResultLabel.text = ""


# -------------------------
# RESET MATCH
# -------------------------
func reset_match():

	player_wins = 0
	computer_wins = 0
	draws = 0
	total_games = 0

	update_scoreboard()
	reset_game()


# -------------------------
# SCOREBOARD UI
# -------------------------
func update_scoreboard():

	player_score_label.text = "Player: " + str(player_wins)
	computer_score_label.text = "Computer: " + str(computer_wins)
	draw_score_label.text = "Draws: " + str(draws)


# -------------------------
# BUTTON SIGNALS
# -------------------------
func _on_button_pressed() -> void:
	make_move($GridContainer/Button)

func _on_button_2_pressed() -> void:
	make_move($GridContainer/Button2)

func _on_button_3_pressed() -> void:
	make_move($GridContainer/Button3)

func _on_button_4_pressed() -> void:
	make_move($GridContainer/Button4)

func _on_button_5_pressed() -> void:
	make_move($GridContainer/Button5)

func _on_button_6_pressed() -> void:
	make_move($GridContainer/Button6)

func _on_button_7_pressed() -> void:
	make_move($GridContainer/Button7)

func _on_button_8_pressed() -> void:
	make_move($GridContainer/Button8)

func _on_button_9_pressed() -> void:
	make_move($GridContainer/Button9)


# -------------------------
# RESET BUTTON
# -------------------------
func _on_reset_button_pressed() -> void:
	reset_match()

# Author: Bianca Butler bb3424 lines 377-386
func show_revive_popup():
	var ui = get_tree().get_first_node_in_group("ui")
	ui.show_revive_popup()
	revive_pending = true

func hide_revive_popup():
	var ui = get_tree().get_first_node_in_group("ui")
	if ui:
		ui.hide_revive_popup()
	revive_pending = false
