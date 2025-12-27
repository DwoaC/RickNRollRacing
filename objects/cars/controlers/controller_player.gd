class_name ControllerPlayer
extends Controller

var input_turn_left: String
var input_turn_right: String
var input_accelerate: String
var input_brake: String
var input_fire: String

func _ready() -> void:
	set_car(car)

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed(input_accelerate):
		accelerate.emit()
	if Input.is_action_pressed(input_brake):
		_brake.emit()
	if Input.is_action_pressed(input_turn_left):
		steer_left.emit()
	if Input.is_action_pressed(input_turn_right):
		steer_right.emit()
		
func _input(event):
	# Check if the specific action was JUST pressed down
	if event.is_action_pressed(input_fire): 
		fire_weapon.emit()

func set_car(new_car):
	super(new_car)
	if car:
		input_accelerate = "accelerate" + "_" + car.stats.player_reference
		input_brake = "brake" + "_" + car.stats.player_reference
		input_turn_left = "turn_left" + "_" + car.stats.player_reference
		input_turn_right = "turn_right" + "_" + car.stats.player_reference
		input_fire = "fire"  + "_" + car.stats.player_reference
