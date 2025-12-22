class_name AI
extends Car

@export var min_look_ahead: float = 5.0

@export var stuck_speed_threshold: float = 0.5  

var look_ahead_distance:
	get:
		return get_dynamic_look_ahead_distance()
	
var speed_multiplier = 2

func process_controls(delta: float) -> void:
	if not track: 
		return
	process_steering(delta)
	process_engine(delta)
	process_avoidence(delta)
	steering = clamp(steering, -steer_angle, steer_angle)
	$Whiskers.distance = look_ahead_distance + 5
	
func process_engine(delta):
	var curve = track.main_path.curve
	var dir_to_target = get_direction_to_target(curve, look_ahead_distance)
	var side_dot = global_transform.basis.x.dot(dir_to_target)
	
	if abs(side_dot) > 0.6:
		brake = brake_force_value
		engine_force = 0
	elif abs(side_dot) > 0.3:
		brake = 0		
		engine_force = 0
	else:
		brake = 0		
		engine_force = engine_force_value
		
	if current_speed < 10:
		brake = 0		
		engine_force = engine_force_value

func process_steering(delta):
	var curve = track.main_path.curve
	var dir_to_target = get_direction_to_target(curve, look_ahead_distance/3)
	var side_dot = global_transform.basis.x.dot(dir_to_target)
	
	steering = clamp(lerp(steering, side_dot * .8, delta * 10), -steer_angle, steer_angle)
	
func get_dynamic_look_ahead_distance() -> float:
	var current_speed = linear_velocity.length()
	return min_look_ahead + (current_speed * speed_multiplier)

func get_direction_to_target(curve: Curve3D, look_ahead_distance) -> Vector3:
	# 1. Find where we are on the path (local coordinates)
	var local_pos = track.main_path.to_local(global_position)
	var current_offset = curve.get_closest_offset(local_pos)
	var track_length = curve.get_baked_length()
	
	# 2. Look at a point further down the track
	var target_offset = fmod(current_offset + look_ahead_distance, track_length)
	#target_offset = clamp(target_offset, 0, 10)
	var target_pos_local = curve.sample_baked(target_offset)
	var target_pos_world = track.main_path.to_global(target_pos_local)
	
	# 3. Steering Logic: Direction to target
	var dir_to_target = global_position.direction_to(target_pos_world).normalized()
	return dir_to_target

func process_avoidence(delta) -> void:
	var avoidance = 0.0
	
	if $Whiskers/Forward.is_colliding():
		var collider: Node3D =  $Whiskers/Forward.get_collider(0)	
		if collider is Car and collider != self:
			if fire_weapon():
				return		
			steering -= steer_angle	
			
	if $Whiskers/Left.is_colliding():
		var collider: Node3D =  $Whiskers/Left.get_collider(0)
		if collider is Car and collider != self:
			steering += steer_angle
		
	if $Whiskers/Right.is_colliding():
		var collider: Node3D =  $Whiskers/Right.get_collider(0)
		
		if collider is Car and collider != self:
			steering -= steer_angle

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
