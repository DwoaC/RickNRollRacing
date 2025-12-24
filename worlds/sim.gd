extends Node3D

@onready var world: World = %World
var players: Array[PlayerCar]

func _ready() -> void:
	world.start()
