extends Car
class_name Player

var reversing = false
@export_group("Controls")
@export var input_turn_left: String = "turn_left"
@export var input_turn_right: String = "turn_right"
@export var input_accelerate: String = "accelerate"
@export var input_brake: String = "brake"
@export var input_fire: String = "fire"

func process_controls(delta):
	process_engine(delta)
	process_stearing(delta)

func process_stearing(delta):
	if Input.is_action_pressed(input_turn_left):
		steering = steer_angle
	elif Input.is_action_pressed(input_turn_right):
		steering = -steer_angle
	else:
		steering = 0.0

func process_engine(delta):
	if Input.is_action_pressed(input_accelerate):
		engine_force = engine_force_value
		brake = 0.0
		reversing = false
	elif Input.is_action_pressed(input_brake):
		if current_speed > 0.5:
			brake = brake_force_value 
			engine_force = 0.0
			reversing = false
		elif reversing:
			engine_force = -engine_force_value * 0.4
			brake = 0.0
			reversing = true
			
		else:
			reversing = true
	else:
		engine_force = 0.0
		brake = 0.0
		reversing = false

func _input(event):
	# Check if the specific action was JUST pressed down
	if event.is_action_pressed(input_fire): 
		fire_weapon()
