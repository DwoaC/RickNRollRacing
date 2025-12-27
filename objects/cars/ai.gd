extends Car

#func process_controls(delta: float) -> void:
	#if not track: 
		#return
	#process_steering(delta)
	#process_engine(delta)
	#process_avoidence(delta)
	#steering = clamp(steering, -steer_angle, steer_angle)
	#$Whiskers.distance = look_ahead_distance + 5
	#
#func process_engine(delta):
	#var curve = track.main_path.curve
	#var dir_to_target = get_direction_to_target(curve, look_ahead_distance)
	#var side_dot = global_transform.basis.x.dot(dir_to_target)
	#
	#if abs(side_dot) > 0.6:
		#brake = brake_force_value
		#engine_force = 0
	#elif abs(side_dot) > 0.3:
		#brake = 0		
		#engine_force = 0
	#else:
		#brake = 0		
		#engine_force = engine_force_value
		#
	#if current_speed < 10:
		#brake = 0		
		#engine_force = engine_force_value
#
#func process_steering(delta):
	#var curve = track.main_path.curve
	#var dir_to_target = get_direction_to_target(curve, look_ahead_distance/3)
	#var side_dot = global_transform.basis.x.dot(dir_to_target)
	#
	#steering = clamp(lerp(steering, side_dot * .8, delta * 10), -steer_angle, steer_angle)
#
#func process_avoidence(delta) -> void:
	#var avoidance = 0.0
	#
	#if $Whiskers/Forward.is_colliding():
		#var collider: Node3D =  $Whiskers/Forward.get_collider(0)	
		#if collider is Car and collider != self:
			#if fire_weapon():
				#return		
			#steering -= steer_angle	
			#
	#if $Whiskers/Left.is_colliding():
		#var collider: Node3D =  $Whiskers/Left.get_collider(0)
		#if collider is Car and collider != self:
			#steering += steer_angle
		#
	#if $Whiskers/Right.is_colliding():
		#var collider: Node3D =  $Whiskers/Right.get_collider(0)
		#
		#if collider is Car and collider != self:
			#steering -= steer_angle

func process_flipped(delta: float) -> void:
	# Get current speed (meters per second)
	var current_speed = linear_velocity.length()
	
	# If moving slower than the threshold...
	if current_speed < stuck_speed_threshold:
		flip_timer += delta
		if flip_timer >= flip_threshold:
			flip_timer = 0.0			
			reset_car_to_track()
	else:
		# Reset the timer if we are moving again
		flip_timer = 0.0
