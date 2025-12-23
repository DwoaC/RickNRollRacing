# GameManager.gd (Autoload)
extends Node

var current_level_node = null

func load_level(level_path: String):
	# 1. Show Loading Screen
	# 2. Instance the new level
	var level_scene = load(level_path)
	var new_level = level_scene.instantiate()
	
	# 3. Clear old level
	if current_level_node:
		current_level_node.queue_free()
	
	# 4. Add to the Main container
	get_tree().root.get_node("Main/LevelContainer").add_child(new_level)
	current_level_node = new_level
