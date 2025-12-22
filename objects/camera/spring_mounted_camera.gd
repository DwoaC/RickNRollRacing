class_name CameraPivot
extends Node3D
@export_group("Camera Settings")
@export var follow_speed: float = 10.0   # How 'tight' the spring is
@export var min_fov: float = 75.0       # FOV at standstill
@export var max_fov: float = 100.0      # FOV at top speed
@export var fov_speed: float = 5.0      # How fast FOV reacts
@export var offset: Vector3 = Vector3(0, 0, 0)

@onready var cam: Camera3D = $CameraSpringArm3D/SpringMountedCamera3D
@onready var car: Car = get_parent()

func _physics_process(delta):
	# 1. FOLLOW POSITION (The 'Spring' Action)
	# We use global_position so we can smooth the movement
	var target_pos = car.global_position + offset
	global_position = global_position.lerp(target_pos, follow_speed * delta)
	
	# 2. FOLLOW ROTATION
	# Smoothens the camera turn when the car drifts
	var target_rot = car.global_transform.basis.get_rotation_quaternion()
	global_transform.basis = Basis(global_transform.basis.get_rotation_quaternion().slerp(target_rot, follow_speed * delta))
	#global_transform.rotat
	# 3. SPEED ZOOM (Dynamic FOV)
	# Calculate speed in KM/H (length of velocity vector * 3.6)
	var speed = car.linear_velocity.length() * 3.6
	var target_fov = remap(speed, 0, 150, min_fov, max_fov) 
	cam.set_fov(lerp(cam.fov, target_fov, fov_speed * delta))
