# GameManager.gd (Autoload)
extends Node

var MAX_CARS = 6

var sim_node: Sim = null

func load_level(level_path: String):
	# 1. Show Loading Screen
	# 2. Instance the new level
	var level_scene = load(level_path)
	var new_level = level_scene.instantiate()
	
	# 3. Clear old level
	if sim_node:
		sim_node.queue_free()
	
	# 4. Add to the Main container
	get_tree().root.get_node("Main/LevelContainer").add_child(new_level)
	sim_node = new_level

func add_player(new_player):
	new_player.player_reference = "p" + str(sim_node.player_cars.size() + 1) 
	sim_node.add_player(new_player)
	
func start_sim():
	sim_node.n_ai = MAX_CARS - sim_node.player_cars.size()
	sim_node.start()
