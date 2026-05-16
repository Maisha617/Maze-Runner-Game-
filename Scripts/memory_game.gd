extends Control
# Author: Maisha Rahman

var previous_level := ""

var fronts = [
	preload("res://memory_game_images/The_Box_Card.png"),
	preload("res://memory_game_images/The_Changing_Card.jpg"),
	preload("res://memory_game_images/The_Glade_Card.jpg"),
	preload("res://memory_game_images/The_Maze_Card.jpg"),
	preload("res://memory_game_images/The_WCKD_Card.jpg"),
]

var cards = []
var assigned_textures = []
var flipped_cards = []
var solved_cards = []
var move_count = 0
var max_tries = 10
var matched_pairs = 0
var total_pairs = 5

var game_started = false
var game_over = false
var revive_pending := false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	previous_level = get_tree().current_scene.scene_file_path

	cards = [
		$Control/Card1, $Control/Card2, $Control/Card3, $Control/Card4, $Control/Card5,
		$Control/Card6, $Control/Card7, $Control/Card8, $Control/Card9, $Control/Card10
	]

	# Builds deck of 2 matching pairs
	var deck = fronts + fronts
	deck.shuffle()

	for i in range(cards.size()):
		var card = cards[i]
		var front_texture = deck[i]

		assigned_textures.append(front_texture)
		card.set_front_texture(front_texture)
		card.show_back()

		card.get_node("CardTemplate").connect("pressed", Callable(self, "_on_card_pressed").bind(card))
	
	# Intro sequence
	
	$StartOverlay/TitleLabel.text = "MEMORY GAME"
	$StartOverlay/InstructionsLabel.text = "Match all pairs in 10 tries to win!"
	
	fade_in($StartOverlay)
	disable_all_cards()

	await get_tree().create_timer(5.0).timeout  
	await fade_out($StartOverlay)

	enable_all_cards()
	game_started = true
	update_ui()

func fade_in(node):
	node.visible = true
	node.mouse_filter = Control.MOUSE_FILTER_STOP
	node.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(node, "modulate:a", 1.0, 0.5)
	return tween

func fade_out(node):
	var tween = create_tween()
	tween.tween_property(node, "modulate:a", 0.0, 0.5)
	await tween.finished
	node.visible = false
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return tween

func _on_card_pressed(card):
	if game_over:
		return
	if flipped_cards.size() >= 2:
		return
	if card in flipped_cards:
		return
	if card in solved_cards:
		return
		
	$Audio_Flip_Click.play()

	card.flip_to_front()
	flipped_cards.append(card)

	if flipped_cards.size() == 2:
		move_count += 1
		update_ui()
		
		check_match()

func check_match():
	var card1 = flipped_cards[0]
	var card2 = flipped_cards[1]

	var tex1 = card1.get_meta("front_texture")
	var tex2 = card2.get_meta("front_texture")

	if tex1 == tex2:
		matched_pairs += 1
		solved_cards.append(card1)
		solved_cards.append(card2)

		card1.get_node("CardTemplate").disabled = true
		card2.get_node("CardTemplate").disabled = true

		flipped_cards.clear()
		
		if move_count >= max_tries and matched_pairs < total_pairs:
			
			# Author: Bianca Butler bb3424 lines 123-126
			if GameState.has_revive:
				revive_pending = true
				show_revive_popup()
				return
			
			game_over = true 
			show_end_screen(false)
			return

		if matched_pairs == total_pairs:
			show_end_screen(true)
		return
	else:
		
		await get_tree().create_timer(1.0).timeout
		
		$Audio_Flip_Back.play()

		for c in flipped_cards:
			c.flip_to_back()

		flipped_cards.clear()

		if move_count >= max_tries:
			# Author: Bianca Butler bb3424 lines 142-145
			if GameState.has_revive:
				revive_pending = true
				show_revive_popup()
				return
			game_over = true
			show_end_screen(false)

func update_ui():
	$Control/TriesLabel.text = "Tries: %d / %d" % [move_count, max_tries]


func disable_all_cards():
	for c in cards:
		c.get_node("CardTemplate").disabled = true


func enable_all_cards():
	for c in cards:
		c.get_node("CardTemplate").disabled = false

func show_end_screen(win: bool):
	disable_all_cards()

	if win:
		$Audio_Win.play()
		$EndOverlay/TitleLabel2.text = "You Win!"
	else:
		$Audio_Lose.play()
		$EndOverlay/TitleLabel2.text = "You Lose"

	$EndOverlay.visible = true
	
	#Resets alpha values before fading 
	$EndOverlay/ColorRect.modulate.a = 0
	$EndOverlay/TitleLabel2.modulate.a = 0
	$EndOverlay/InstructionsLabel2.modulate.a = 0
	
	var tween = create_tween()
	
	# Fades in background first
	tween.tween_property($EndOverlay/ColorRect, "modulate:a", 1.0, 0.6)

	# Once background is visible, block clicks
	tween.tween_callback(func():
		$EndOverlay/ColorRect.mouse_filter = Control.MOUSE_FILTER_STOP
	)

	tween.tween_property($EndOverlay/TitleLabel2, "modulate:a", 1.0, 0.4)
	tween.tween_property($EndOverlay/InstructionsLabel2, "modulate:a", 1.0, 0.4)

func _input(event):
	if revive_pending:
		return

	if game_over and not revive_pending and event.is_pressed():
		get_tree().change_scene_to_file(GameState.current_level)

	if game_started and matched_pairs == total_pairs and event.is_pressed():
		if GameState.current_level == "res://Scenes/Environment.tscn":
			get_tree().change_scene_to_file("res://Scenes/SecondLevel.tscn")
		elif GameState.current_level == "res://Scenes/SecondLevel.tscn":
			get_tree().change_scene_to_file("res://Scenes/ThirdLevel.tscn")
		elif GameState.current_level == ("res://Scenes/ThirdLevel.tscn"):
			get_tree().change_scene_to_file("res://Scenes/FourthLevel.tscn")
		elif GameState.current_level == ("res://Scenes/FourthLevel.tscn"):
			get_tree().change_scene_to_file("res://Scenes/FifthLevel.tscn")
			
			
# Author: Bianca Butler bb3424 lines 215-250
func show_revive_popup():
	get_node("CanvasLayer/RevivePopup").visible = true

	disable_all_cards()

func hide_revive_popup():
	get_node("CanvasLayer/RevivePopup").visible = false



func _on_yes_button_pressed():
	if revive_pending:
		revive_pending = false
		GameState.has_revive = false

# Hide revive icon in global UI
	var ui = get_tree().get_first_node_in_group("ui")
	if ui:
		ui.hide_powerup_icon()

# Reset tries
	move_count = 0
	update_ui()

# Flash effect
	$Control.modulate = Color(0.5, 1, 0.5)
	await get_tree().create_timer(0.3).timeout
	$Control.modulate = Color(1, 1, 1)

	hide_revive_popup()

# Move to next level
	if GameState.current_level == "res://Scenes/Environment.tscn":
		GameState.current_level = "res://Scenes/SecondLevel.tscn"
		get_tree().change_scene_to_file(GameState.current_level)

	elif GameState.current_level == "res://Scenes/SecondLevel.tscn":
		GameState.current_level = "res://Scenes/ThirdLevel.tscn"
		get_tree().change_scene_to_file(GameState.current_level)

	elif GameState.current_level == "res://Scenes/ThirdLevel.tscn":
		GameState.current_level = "res://Scenes/FourthLevel.tscn"
		get_tree().change_scene_to_file(GameState.current_level)

	elif GameState.current_level == "res://Scenes/FourthLevel.tscn":
		GameState.current_level = "res://Scenes/FifthLevel.tscn"
		get_tree().change_scene_to_file(GameState.current_level)



func _on_no_button_pressed():
	revive_pending = false
	hide_revive_popup()
	game_over = true
	show_end_screen(false)
