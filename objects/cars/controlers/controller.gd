class_name Controller
extends Node

var car: Car
var stats: CarStats:
	get:
		return car.stats

var steering
var engine_force
var brake
var reversing
var current_speed: float = 0

signal input_provided(throttle: float, steering: float, brake: float)
signal fire_weapon()

func possess(_car: Car):
	car = _car
