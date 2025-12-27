class_name ControllerAI
extends Controller

#func process_controls(delta: float) -> void:
var steering: float = 0.0

func _physics_process(delta: float) -> void:
	if not car:
		return
	steering = 0.0
	process_engine(delta)
	process_steering(delta)
	process_whiskers(delta)
	
	if steering > 0.0:
		steer_left.emit()
	elif steering < 0.0:
		steer_right.emit()

func process_engine(delta):
	var curve = car.track.main_path.curve
	var dir_to_target = car.get_direction_to_target(curve, car.look_ahead_distance)
	var side_dot = car.global_transform.basis.x.dot(dir_to_target)
	
	if abs(side_dot) > 0.6:
		_brake.emit()
	elif abs(side_dot) > 0.3:
		pass
	else:
		accelerate.emit()
		
	if car.current_speed < 10:
		accelerate.emit()
#
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
		print('not car')
		return
		
	if not car.whisker_left:
		print('not left ' + str(car.whisker_left))
		return
	if not car.whisker_forward:
		print('not right')
		return
	if not car.whisker_forward:
		print('not forward')
		return
	var avoidance = 0.0
	
	if car.whisker_forward.is_colliding():
		print("forward")
		var collider: Node3D =  car.whisker_forward.get_collider(0)	
		if collider is Car and collider != self:
			print('fire')
			fire_weapon.emit()
			
			steering -= car.stats.steer_angle	
			
	if car.whisker_left.is_colliding():
		print("left")
		
		var collider: Node3D =  car.whisker_left.get_collider(0)
		if collider is Car and collider != self:
			steering += car.stats.steer_angle
		
	if car.whisker_right.is_colliding():
		print("right")
		
		var collider: Node3D =  car.whisker_right.get_collider(0)
		
		if collider is Car and collider != self:
			steering -= car.stats.steer_angle
