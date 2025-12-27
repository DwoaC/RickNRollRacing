extends Control

@onready var first_button = %SinglePlayerButton

var previous_menu: Control

var current_menu: Control:
	set(new_menu):
		print('changing from ' + str(current_menu) + ' to ' + str(new_menu))
		if current_menu:
			current_menu.hide()
			previous_menu = current_menu
			
		new_menu.show()
		
		for node in new_menu.get_children():
			if node is Button:
				first_button = node
				break
		if first_button:
			first_button.grab_focus()

		current_menu = new_menu

func _ready():
	# VERY IMPORTANT: This tells the controller which button to start on
	first_button.grab_focus()
	current_menu = %TopMenu
	%SinglePlayerButton.pressed.connect(_on_single_player_btn_pressed) 
	%QuickRaceButton.pressed.connect(_on_quick_race_button_pressed)
	%SettingsButton.pressed.connect(_on_settings_btn_pressed)
	%QuitButton.pressed.connect(_on_quit_btn_pressed)
	
	%TwoPlayerButton.pressed.connect(_on_two_player_btn_pressed) 
	%ThreePlayerButton.pressed.connect(_on_three_player_btn_pressed) 
	%FourPlayerButton.pressed.connect(_on_four_player_btn_pressed) 
	%MultiplayerBack.pressed.connect(_on_back_pressed) 
	
func _on_quick_race_button_pressed():
	current_menu = %MultiplayerMenu

func _on_settings_btn_pressed():
	pass

func _on_quit_btn_pressed():
	get_tree().quit()
	
func _on_single_player_btn_pressed():
	GamerManager.load_level("res://worlds/Sim.tscn")
	
	for i in range(5):
		var ai = load("res://resources/ai_stats.tres")
		GamerManager.add_ai(ai)
	
	var player = load("res://resources/player_1.tres")
	GamerManager.add_player(player)
	
	GamerManager.start_sim()
	hide()

func _on_two_player_btn_pressed():
	GamerManager.load_level("res://worlds/Sim.tscn")

	for i in range(4):
		var ai = load("res://resources/ai_stats.tres")
		GamerManager.add_ai(ai)
	
	var player = load("res://resources/player_1.tres")
	GamerManager.add_player(player)
	
	player = load("res://resources/player_2.tres")
	GamerManager.add_player(player)
	
	GamerManager.start_sim()
	hide()
	
func _on_three_player_btn_pressed():
	GamerManager.load_level("res://worlds/Sim.tscn")

	for i in range(3):
		var ai = load("res://resources/ai_stats.tres")
		GamerManager.add_ai(ai)
	
	var player = load("res://resources/player_1.tres")
	GamerManager.add_player(player)
	
	player = load("res://resources/player_2.tres")
	GamerManager.add_player(player)
	
	player = load("res://resources/player_3.tres")
	GamerManager.add_player(player)
		
	GamerManager.start_sim()
	hide()

func _on_four_player_btn_pressed():
	GamerManager.load_level("res://worlds/Sim.tscn")

	for i in range(2):
		var ai = load("res://resources/ai_stats.tres")
		GamerManager.add_ai(ai)
	
	var player = load("res://resources/player_1.tres")
	GamerManager.add_player(player)
	
	player = load("res://resources/player_2.tres")
	GamerManager.add_player(player)
	
	player = load("res://resources/player_3.tres")
	GamerManager.add_player(player)
	
	player = load("res://resources/player_4.tres")
	GamerManager.add_player(player)
	
	GamerManager.start_sim()
	hide()

func _on_back_pressed() -> void:
	current_menu = previous_menu
