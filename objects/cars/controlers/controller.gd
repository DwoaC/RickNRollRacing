class_name Controller
extends Node

var _car: Car
var car: Car:
	get:
		return _car
	set(new_car):
		set_car(new_car)

signal input_provided(throttle: float, steering: float, brake: float)
signal fire_weapon()
signal accelerate()
signal _brake()
signal steer_left()
signal steer_right()

signal steering_signal(steering: float)
signal engine_force_signal(engine_force: float)
signal brake_signal(brake: float)

func set_car(new_car: Car):
	_car = new_car
