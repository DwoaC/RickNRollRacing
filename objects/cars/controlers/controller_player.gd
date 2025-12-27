class_name ControllerPlayer
extends Controller

var input_turn_left: String
var input_turn_right: String
var input_accelerate: String
var input_brake: String
var input_fire: String


func _ready() -> void:
	input_accelerate = "accelerate" + "_" + stats.player_reference
	input_brake = "brake" + "_" + stats.player_reference
	input_turn_left = "turn_left" + "_" + stats.player_reference
	input_turn_right = "turn_right" + "_" + stats.player_reference
	input_fire = "fire"  + "_" + stats.player_reference

func _physics_process(delta: float) -> void:
	process_controls(delta)

func process_controls(delta):
	process_engine(delta)
	process_stearing(delta)
	input_provided.emit(engine_force, steering, brake)

func process_stearing(delta):
	if Input.is_action_pressed(input_turn_left):
		steering = stats.steer_angle
	elif Input.is_action_pressed(input_turn_right):
		steering = -stats.steer_angle
	else:
		steering = 0.0

func process_engine(delta):
	if Input.is_action_pressed(input_accelerate):
		engine_force = stats.engine_force_value
		brake = 0.0
		reversing = false
	elif Input.is_action_pressed(input_brake):
		if current_speed > 0.5:
			brake = stats.brake_force_value 
			engine_force = 0.0
			reversing = false
		elif reversing:
			engine_force = -stats.engine_force_value * 0.4
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
		fire_weapon.emit()
