extends Car
class_name PlayerCar

@export_group("Controls")

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
