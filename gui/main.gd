extends Node

@onready var level_container = $LevelContainer
@onready var ui_layer = $UILayer

func trigger_level_load(path: String):
	for child in level_container.get_children():
		child.queue_free()
		
	# 2. Add the Loading Screen UI
	var loader = load("res://gui/loading_screen.tscn").instantiate()
	loader.scene_path = path
	ui_layer.add_child(loader)
	

func finalize_load(new_level_resource: PackedScene):
	var level_instance = new_level_resource.instantiate()
	level_container.add_child(level_instance)
	
	# 3. Position the Player at the level's SpawnPoint
	spawn_player(level_instance)

func spawn_player(level):
	pass
