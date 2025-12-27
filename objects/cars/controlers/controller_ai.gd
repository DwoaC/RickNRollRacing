class_name ControllerAI
extends Controller

func process_controls(delta: float) -> void:
	process_steering(delta)
	process_engine(delta)
	process_avoidence(delta)
	steering = clamp(steering, -stats.steer_angle, stats.steer_angle)
	car.whiskers.distance = car.look_ahead_distance + 5
	
func process_engine(delta):
	var curve = car.track.main_path.curve
	var dir_to_target = car.get_direction_to_target(curve, car.look_ahead_distance)
	var side_dot = car.global_transform.basis.x.dot(dir_to_target)
	
	if abs(side_dot) > 0.6:
		brake = stats.brake_force_value
		engine_force = 0
	elif abs(side_dot) > 0.3:
		brake = 0		
		engine_force = 0
	else:
		brake = 0		
		engine_force = stats.engine_force_value
		
	if current_speed < 10:
		brake = 0		
		engine_force = stats.engine_force_value

func process_steering(delta):
	var curve = car.track.main_path.curve
	var dir_to_target = car.get_direction_to_target(curve, car.look_ahead_distance/3)
	var side_dot = car.global_transform.basis.x.dot(dir_to_target)
	
	steering = clamp(
		lerp(steering, side_dot * .8, delta * 10), 
		-stats.steer_angle, 
		stats.steer_angle
	)

func process_avoidence(delta) -> void:
	var avoidance = 0.0
	
	if $Whiskers/Forward.is_colliding():
		var collider: Node3D =  $Whiskers/Forward.get_collider(0)	
		if collider is Car and collider != self:
			fire_weapon.emit()
			
			steering -= stats.steer_angle	
			
	if $Whiskers/Left.is_colliding():
		var collider: Node3D =  $Whiskers/Left.get_collider(0)
		if collider is Car and collider != self:
			steering += stats.steer_angle
		
	if $Whiskers/Right.is_colliding():
		var collider: Node3D =  $Whiskers/Right.get_collider(0)
		
		if collider is Car and collider != self:
			steering -= stats.steer_angle
