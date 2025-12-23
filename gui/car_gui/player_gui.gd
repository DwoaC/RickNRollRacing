extends VBoxContainer
class_name CarGUI

@export var car: Car



func _ready():
	# Assuming your car is a child of the level
	car = get_parent().car
	if car:
		
		car.suspension_updated.connect(_on_player_suspension_updated)
		$SuspensionTuningBox/Stiffness.value = car.wheels[0].suspension_stiffness
		$SuspensionTuningBox/Stiffness.value_changed.connect(_on_car_suspension_stiffness_updated)
		
		$SuspensionTuningBox/MaxForce.value = car.wheels[0].suspension_max_force
		$SuspensionTuningBox/MaxForce.value_changed.connect(_on_car_suspension_maxforce_updated)
		
		$SuspensionTuningBox/DampingCompression.value = car.wheels[0].damping_compression
		$SuspensionTuningBox/DampingCompression.value_changed.connect(_on_car_suspension_damping_compression_updated)
		
		$SuspensionTuningBox/DampingRelaxation.value = car.wheels[0].damping_relaxation
		$SuspensionTuningBox/DampingRelaxation.value_changed.connect(_on_car_suspension_damping_relaxation_updated)
		
		$SuspensionTuningBox/RollInfluence.value = car.wheels[0].wheel_roll_influence
		$SuspensionTuningBox/RollInfluence.value_changed.connect(_on_car_suspension_roll_influence_updated)
				
		$SuspensionTuningBox/COGY.value = car.center_of_mass.y
		$SuspensionTuningBox/COGY.value_changed.connect(_on_car_suspension_cogy_updated)
		
		$SuspensionTuningBox/FrictionSlipFront.value = car.wheels[0].wheel_friction_slip
		$SuspensionTuningBox/FrictionSlipFront.value_changed.connect(_on_car_suspension_friction_slip_front_updated)
		
		$SuspensionTuningBox/FrictionSlipRear.value = car.wheels[0].wheel_friction_slip
		$SuspensionTuningBox/FrictionSlipRear.value_changed.connect(_on_car_suspension_friction_slip_rear_updated)

func _on_player_suspension_updated(values: Array[float]) -> void:
	$SuspensionBox.get_node("FLCompression").value = values[0]
	$SuspensionBox.get_node("FRCompression").value = values[1]
	$SuspensionBox.get_node("BLCompression").value = values[2]
	$SuspensionBox.get_node("BRCompression").value = values[3]	
	#print(car.wheels[0].position.y)

func _on_car_suspension_stiffness_updated(value: float) -> void:
	print(value)
	if not car:
		return
	for i in range(car.wheels.size()):
		var wheel: VehicleWheel3D = car.wheels[i]
		wheel.suspension_stiffness = value

func _on_car_suspension_maxforce_updated(value: float) -> void:
	print(value)
	if not car:
		return
	for i in range(car.wheels.size()):
		var wheel: VehicleWheel3D = car.wheels[i]
		wheel.suspension_max_force = value

func _on_car_suspension_damping_compression_updated(value: float) -> void:
	print(value)
	if not car:
		return
	for i in range(car.wheels.size()):
		var wheel: VehicleWheel3D = car.wheels[i]
		wheel.damping_compression = value

func _on_car_suspension_damping_relaxation_updated(value: float) -> void:
	print(value)
	if not car:
		return
	for i in range(car.wheels.size()):
		var wheel: VehicleWheel3D = car.wheels[i]
		wheel.damping_relaxation = value

func _on_car_suspension_roll_influence_updated(value: float) -> void:
	print(value)
	if not car:
		return
	for i in range(car.wheels.size()):
		var wheel: VehicleWheel3D = car.wheels[i]
		wheel.wheel_roll_influence = value

func _on_car_suspension_cogy_updated(value: float) -> void:
	print(value)
	if not car:
		return
	car.center_of_mass.y = value
	
func _on_car_suspension_friction_slip_front_updated(value: float) -> void:
	print(value)
	if not car:
		return
	for i in [0, 1]:
		var wheel: VehicleWheel3D = car.wheels[i]
		wheel.wheel_friction_slip = value
		
func _on_car_suspension_friction_slip_rear_updated(value: float) -> void:
	print(value)
	if not car:
		return
	for i in [2, 3]:
		var wheel: VehicleWheel3D = car.wheels[i]
		wheel.wheel_friction_slip = value
