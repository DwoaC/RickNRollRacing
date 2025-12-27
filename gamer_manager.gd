# GameManager.gd (Autoload)
extends Node

var MAX_CARS = 6
var player_car_scene = preload("res://objects/cars/car_player.tscn")
var ai_car_scene = preload("res://objects/cars/ai.tscn")

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

func add_player(car_stats: PlayerStats) -> void:
	
	car_stats.player_reference = "p" + str(sim_node.player_cars.size() + 1) 
	
	var car: PlayerCar = player_car_scene.instantiate()
	car.stats = car_stats

	sim_node.add_player(car)
	
	var controller_scene = load("res://objects/cars/controlers/controller_player.tscn")
	var controller = controller_scene.instantiate()
	
	controller.stats = car_stats
	car.add_controller(controller)
	
	sim_node.add_viewport(car)
	
func add_ai(car_stats: CarStats) -> void:
	print("car stats: " + str(car_stats))
	var car: Car = ai_car_scene.instantiate()
	car.stats = car_stats
	
	sim_node.add_player(car)

	var controller_scene = load("res://objects/cars/controlers/controller_ai.tscn")
	var controller = controller_scene.instantiate()
	
	controller.stats = car_stats
	car.add_controller(controller)
	
func start_sim():
	sim_node.start()
