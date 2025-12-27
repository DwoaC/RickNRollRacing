extends Resource
class_name CarStats

@export var name: String = "Unknown Driver"
@export var points: int = 0
@export var money: int = 0
@export var car_color: Color = Color.RED
@export var car_type: String = 'A'

@export var engine_force_value: float = 3000.0
@export var brake_force_value: float = 6000.0
@export var steer_angle: float = 0.5   # radians
@export var respawn_delay: float = 1.5
@export var max_speed: float = 75.0 / 3.6
