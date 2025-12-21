extends VehicleBody3D
class_name Car

@export var engine_force_value: float = 3000.0
@export var brake_force_value: float = 6000.0
@export var steer_angle: float = 0.5   # radians
var live_engine_force = 0.0

@onready var wheels := [
	$WheelFrontLeft,
	$WheelFrontRight,
	$WheelBackRight,
	$WheelBackLeft
]

var track: Track

var cross_two_thirds: bool = false
var cross_one_thrid: bool = false
var current_lap: int

signal speed_updated(new_speed: float)
signal suspension_updated(values: Array[float])
signal lap_completed(car: Car)

@onready var initial_y = $WheelFrontLeft.position.y

var current_speed: float:
	get:
		return linear_velocity.dot(transform.basis.z)

func _physics_process(delta):
	process_controls(delta)
	process_suspension(delta)
	_process_lap(delta)
	
func process_controls(delta):
	speed_updated.emit(current_speed)
	
func process_suspension(delta):
	var values: Array[float] = [0.0, 0.0, 0.0, 0.0]
	for i in range(wheels.size()):
		var wheel: VehicleWheel3D = wheels[i]
		
		if wheel.is_in_contact():
			var compression = (initial_y - wheel.position.y) / wheel.suspension_travel * 100
			values[i] = compression
		else:
			values[i] = 0.0
	suspension_updated.emit(values)
	
func on_track_changed(new_track: Track) -> void:
	print("New track: " + str(new_track))
	track = new_track
	current_lap = 0
	
func _process_lap(_delta: float) -> void:
	if not track: 
		return
	
	var curve = track.main_path.curve
	var local_pos = track.main_path.to_local(self.global_position)
	var offset = curve.get_closest_offset(local_pos)
	var progress = offset / curve.get_baked_length()
	
	if progress > 0.33 and progress <= 0.66 and not cross_two_thirds:
		cross_one_thrid = true
	
	if progress > 0.66 and progress < 1 and cross_one_thrid:
		cross_two_thirds = true
	
	if progress == 1 and cross_one_thrid and cross_two_thirds:
		complete_lap()

func complete_lap():
	if current_lap > 0 and not track.is_repeatable:
		return
		
	current_lap += 1
	cross_one_thrid = false
	cross_two_thirds = false

	lap_completed.emit(self)
	
	print("Lap: ", current_lap)
