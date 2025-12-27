class_name Sim
extends Node3D

var MAX_PLAYERS = 4

@export var player_cars: Array[PlayerCar]
@onready var world: World = %World
@onready var viewport_container = %GridContainer


var player_viewport_container = preload("res://worlds/car_sub_viewport_container.tscn")

func start():
	world.start()
	
func add_player(car: Car) -> void:
	player_cars.append(car)
	add_child(car)
	world.cars.append(car)
		
func add_viewport(car: Car):
	var new_player_viewport = player_viewport_container.instantiate()
	new_player_viewport.car = car
	new_player_viewport.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_player_viewport.size_flags_vertical = Control.SIZE_EXPAND_FILL
	new_player_viewport.stretch = true
	viewport_container.add_child(new_player_viewport)
	
	if player_cars.size() > 2:
		viewport_container.columns = 2
	print("Player cars " + str(viewport_container.columns))
