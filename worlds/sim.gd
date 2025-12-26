class_name Sim
extends Node3D

var MAX_PLAYERS = 4

@export var player_cars: Array[PlayerCar]
@onready var world: World = %World
@onready var viewport_container = %GridContainer

var n_ai: int:
	get:
		return world.n_ai
	set(value):
		world.n_ai = value

var player_car_scene = preload("res://objects/cars/player.tscn")
var player_viewport_container = preload("res://worlds/car_sub_viewport_container.tscn")

func _ready() -> void:
	pass
	
func start():
	world.start()
	
func add_player(new_player_stats: PlayerStats):
	if player_cars.size() >= MAX_PLAYERS:
		return
	var new_player_car: PlayerCar = player_car_scene.instantiate()
	new_player_car.player_stats = new_player_stats
	player_cars.append(new_player_car)
	add_child(new_player_car)
	
	world.cars.append(new_player_car)
	
	if player_cars.size() > 2:
		viewport_container.columns = 2
		
	var new_player_viewport = player_viewport_container.instantiate()
	new_player_viewport.car = new_player_car
	new_player_viewport.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_player_viewport.size_flags_vertical = Control.SIZE_EXPAND_FILL
	new_player_viewport.stretch = true
	viewport_container.add_child(new_player_viewport)
