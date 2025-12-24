extends Car
class_name PlayerCar

var reversing = false
@export_group("Controls")
@export var player_reference: String = "p1"

var input_turn_left: String
var input_turn_right: String
var input_accelerate: String
var input_brake: String
var input_fire: String

func _ready() -> void:
	input_accelerate = "accelerate" + "_" + player_reference
	input_brake = "brake" + "_" + player_reference
	input_turn_left = "turn_left" + "_" + player_reference
	input_turn_right = "turn_right" + "_" + player_reference
	input_fire = "fire"  + "_" + player_reference
	
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

func process_flipped(delta):
	var up_dot = global_transform.basis.y.dot(Vector3.UP)
	if up_dot < max_upright_angle and linear_velocity.length() < 1.0:
		flip_timer += delta
		if flip_timer >= flip_threshold:
			if not is_flipped:
				car_flipped.emit(self)
			is_flipped = true
			if Input.is_action_just_pressed("fire"):
				reset_car_to_track()
	else:
		flip_timer = 0.0
		is_flipped = false
