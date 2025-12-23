extends Node3D

@onready var world: World = %World

func _ready() -> void:
	world.start()
