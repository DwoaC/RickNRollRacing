class_name ControllerAI
extends Controller

#func process_controls(delta: float) -> void:
var steering: float = 0.0
var brake: float = 0.0
var engine_force: float = 0.0

func _physics_process(delta: float) -> void:
	if not car:
		return
	process_engine(delta)
	process_steering(delta)
	process_whiskers(delta)
	
	engine_force_signal.emit(engine_force)
	brake_signal.emit(brake)
	steering_signal.emit(steering)

func process_engine(delta):
	var curve = car.track.main_path.curve
	var dir_to_target = car.get_direction_to_target(curve, car.look_ahead_distance)
	var side_dot = car.global_transform.basis.x.dot(dir_to_target)
	
	if abs(side_dot) > 0.6:
		brake = car.brake_force_value
		engine_force = 0
	elif abs(side_dot) > 0.3:
		brake = 0		
		engine_force = 0
	else:
		brake = 0		
		engine_force = car.engine_force_value
		
	if car.current_speed < 10:
		brake = 0		
		engine_force = car.engine_force_value

func process_steering(delta):
	var curve = car.track.main_path.curve
	var dir_to_target = car.get_direction_to_target(curve, car.look_ahead_distance/3)
	var side_dot = car.global_transform.basis.x.dot(dir_to_target)
	steering = clamp(
		lerp(car.steering, side_dot * .8, delta * 10), 
		-car.stats.steer_angle, 
		car.stats.steer_angle
	)

func process_whiskers(delta) -> void:
	if not car:
		return
		
	if not car.whisker_left:
		return
	if not car.whisker_forward:
		return
	if not car.whisker_forward:
		return
	var avoidance = 0.0
	
	if car.whisker_forward.is_colliding():
		var collider: Node3D =  car.whisker_forward.get_collider(0)	
		if collider is Car and collider != self:
			fire_weapon.emit()
			
			#steering -= car.stats.steer_angle	
			
	if car.whisker_left.is_colliding():
		var collider: Node3D =  car.whisker_left.get_collider(0)
		if collider is Car and collider != self:
			steering += car.stats.steer_angle
		
	if car.whisker_right.is_colliding():
		var collider: Node3D =  car.whisker_right.get_collider(0)
		
		if collider is Car and collider != self:
			steering -= car.stats.steer_angle
