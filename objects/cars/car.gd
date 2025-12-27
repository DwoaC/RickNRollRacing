extends VehicleBody3D
class_name Car

@export_group("Engine")
@export var engine_force_value: float = 3000.0
@export var brake_force_value: float = 6000.0
@export var steer_angle: float = 0.5   # radians
@export var respawn_delay: float = 1.5
@export var max_speed: float = 75.0 / 3.6

@export_group('AI')
@export var min_look_ahead: float = 5.0
@export var stuck_speed_threshold: float = 0.5  
@export var speed_multiplier: float = 2


var stats: CarStats:
	get:
		return stats
	set(new_stats):
		stats = new_stats
		color = stats.car_color

var live_engine_force = 0.0
var is_dead = false

var look_ahead_distance:
	get:
		return get_dynamic_look_ahead_distance()

func get_dynamic_look_ahead_distance() -> float:
	var current_speed = linear_velocity.length()
	return min_look_ahead + (current_speed * speed_multiplier)

@onready var wheels: Array[VehicleWheel3D]: 
	get:
		if wheels.is_empty():
			for child in get_children():
				if child is VehicleWheel3D:
					wheels.append(child)
		return wheels
		
var any_wheel_in_contact: bool:
	get:
		for wheel in wheels:
			if wheel.is_in_contact():
				return true
		return false

var track: Track

var cross_two_thirds: bool = false
var cross_one_thrid: bool = false
var current_lap: int
var is_flipped: bool = false

@export_group("Bullets")
@export var bullet_scene: PackedScene = preload("res://objects/bullets/bullet.tscn")
@onready var muzzle = $Muzzle
@export var explosion_scene: PackedScene = preload("res://objects/effects/car_explosion.tscn")
@onready var fire_timer: Timer = $FireTimeout

@export_group("Audio")
@onready var engine_audio_idle = %EngineIdle
@onready var engine_audio_high = %EngineHigh
@onready var fire_sound = %FireSound
@onready var crash_sound = %CrashSound
@onready var tire_squeal_sound = %TireSquealSound
@onready var break_sound = %TireSquealSound

@export var min_pitch: float = 0.6  # Deep idle sound
@export var max_pitch: float = 2.5  # High revving sound
@export var max_speed_for_audio: float = 120.0 / 3.6
@export var crash_threshold: float = 5.0 # Minimum speed impact to trigger sound
@export var squeal_threshold: float = 2.0  # How much slip triggers sound
@export var squeal_max_vol: float = 0.0    # Max volume in DB
@export var brake_squeal_threshold: float = 2.0 # Speed above which brakes squeal
@export var brake_sensitivity: float = 0.5     # How hard you must press to hear it

var flip_timer: float = 0.0
@export var flip_threshold: float = 2.0 # Seconds to wait before resetting
@export var max_upright_angle: float = 0.5

var last_velocity: Vector3 = Vector3.ZERO
var reversing: bool = false

signal speed_updated(new_speed: float)
signal suspension_updated(values: Array[float])
signal lap_completed(car: Car)
signal car_flipped(car: Car)
signal car_reset(car: Car)

@onready var initial_y = $WheelFrontLeft.position.y
@onready var whisker_forward = %Forward
@onready var whisker_left = %Left
@onready var whisker_right = %Right


var current_speed: float:
	get:
		return linear_velocity.dot(transform.basis.z)
		
var color: Color :
	set(value):
		if material:
			var new_material: StandardMaterial3D = material.duplicate()
			new_material.albedo_color = value
			material = new_material
		else:
			return
		
var material: StandardMaterial3D:
	get:
		if mesh:
			return mesh.get_active_material(0)
		else:
			return
	set(new_material):
		mesh.set_surface_override_material(0, new_material)
		
@onready var mesh: MeshInstance3D = %MeshInstance3D

func _ready() -> void:
	color = stats.car_color

func _physics_process(delta):
	engine_force = 0.0
	brake = 0.0
	steering = 0.0
	
	if is_dead:
		return
	process_controls(delta)
	stabilize_muzzle()	
	process_suspension(delta)
	process_lap(delta)
	process_audio(delta)
	emit_updates()	
	detect_crash(delta)
	process_flipped(delta)
	if current_speed > max_speed:
		engine_force = 0
	
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

func detect_crash(delta):
	var current_velocity = linear_velocity
	
	var impulse = (last_velocity - current_velocity).length()
	
	if impulse > crash_threshold:
		play_crash_sound(impulse)
		
	last_velocity = current_velocity
	
func play_crash_sound(force):
	# Don't play if it's already playing (prevents "machine gun" sound)
	if not crash_sound.playing:
		# Randomize pitch slightly so every crash sounds unique
		crash_sound.pitch_scale = randf_range(0.8, 1.2)
		
		# Make louder impacts sound louder
		var volume = remap(force, crash_threshold, 30.0, -10.0, 5.0)
		crash_sound.volume_db = clamp(volume, -15.0, 5.0)
		
		crash_sound.play()
	
func process_audio(delta):
	process_engine_audio(delta)
	process_tire_squeal(delta)
	process_brake_audio(delta)

func process_engine_audio(delta):
	var target_pitch = remap(current_speed, 0, max_speed_for_audio, min_pitch, max_pitch)
	
	engine_audio_idle.pitch_scale = clamp(target_pitch, min_pitch, max_pitch)
	engine_audio_idle.volume_db = remap(current_speed, 0, max_speed_for_audio * 0.66, -10, 0)
	
	engine_audio_high.pitch_scale = clamp(target_pitch, min_pitch, max_pitch)
	engine_audio_high.volume_db = remap(current_speed, max_speed_for_audio * 0.33, max_speed_for_audio, -10, 0)
	
	var mix_ratio = clamp(current_speed / max_speed_for_audio, 0.0, 1.0)
	
	engine_audio_idle.volume_db = linear_to_db(1.0 - mix_ratio)
	engine_audio_high.volume_db = linear_to_db(mix_ratio)
	
func process_brake_audio(delta):
	var current_speed = linear_velocity.length()
	
	# We check if the player is pressing the brake (usually Input.get_axis or similar)
	# In VehicleBody3D, 'brake' is a float property
	var is_braking = brake > brake_sensitivity
	
	if is_braking and current_speed > brake_squeal_threshold:
		if not break_sound.playing:
			break_sound.play()
		
		# Volume increases with speed and brake pressure
		var pressure_factor = clamp(brake / 10.0, 0.0, 1.0) # Normalizing brake force
		var target_vol = remap(current_speed * pressure_factor, 0, 30, -25.0, 0.0)
		
		break_sound.volume_db = lerp(break_sound.volume_db, target_vol, 0.1)
		
		# Brakes often "shriek" higher as they get hotter/faster
		break_sound.pitch_scale = lerp(break_sound.pitch_scale, 1.2, 0.05)
	else:
		# Fade out smoothly
		break_sound.volume_db = lerp(break_sound.volume_db, -40.0, 0.2)
		if break_sound.volume_db < -39:
			break_sound.stop()
	
func process_tire_squeal(delta):
	if not any_wheel_in_contact:
		tire_squeal_sound.stop()
		return
		
	var side_velocity = linear_velocity.dot(global_transform.basis.x)
	var abs_side_slip = abs(side_velocity)
	
	var engine_slip = 0.0
	if linear_velocity.length() < 5.0 and engine_force > 500:
		engine_slip = 5.0 

	var total_slip = abs_side_slip + engine_slip

	# 3. Audio Control
	if total_slip > squeal_threshold:
		if not tire_squeal_sound.playing:
			tire_squeal_sound.play()
		
		# Fade volume in based on slip intensity
		var target_vol = remap(total_slip, squeal_threshold, 15.0, -20.0, squeal_max_vol)
		tire_squeal_sound.volume_db = lerp(tire_squeal_sound.volume_db, target_vol, 0.2)
		
		# Higher pitch for faster slides
		tire_squeal_sound.pitch_scale = remap(total_slip, squeal_threshold, 20.0, 0.8, 1.2)
	else:
		# Fade out volume instead of stopping abruptly
		tire_squeal_sound.volume_db = lerp(tire_squeal_sound.volume_db, -40.0, 0.1)
		if tire_squeal_sound.volume_db < -39:
			tire_squeal_sound.stop()
	
func emit_updates():
	speed_updated.emit(current_speed)
	
func process_controls(delta):
	pass
	
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
	
func process_lap(_delta: float) -> void:
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

func fire_weapon() -> bool:
	if not bullet_scene: 
		return false
		
	if not fire_timer.is_stopped():
		return false
	
	var bullet: Node3D = bullet_scene.instantiate()
	bullet.source = self
	
	get_tree().root.add_child(bullet)
	
	bullet.global_transform = muzzle.global_transform
	bullet.global_rotation.x = 0
	bullet.global_rotation.z = 0
	
	var car_speed = linear_velocity.length()
	bullet.speed += car_speed
	
	fire_timer.start()
	return true

func take_damage(damage, source):
	is_dead = true
	visible = false
	process_mode = PROCESS_MODE_DISABLED
	
	spawn_explosion_visuals()
	await get_tree().create_timer(respawn_delay).timeout
	respawn()

func reset_car_to_track():
	if not track:
		return
		
	var curve = track.main_path.curve
	var current_offset = curve.get_closest_offset(track.main_path.to_local(global_position))
	
	var respawn_pos = track.main_path.to_global(curve.sample_baked(current_offset - 5.0))
	var look_at_pos = track.main_path.to_global(curve.sample_baked(current_offset + 5.0))
	
	global_position = respawn_pos
	look_at(look_at_pos, Vector3.UP, true)
	
	global_position.y += 1.0
	
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	car_reset.emit(self)

func respawn():
	is_dead = false	
	visible = true
	process_mode = PROCESS_MODE_INHERIT
	
	reset_car_to_track()
	
func spawn_explosion_visuals():
	if not explosion_scene: 
		return
	
	var exp = explosion_scene.instantiate()
	get_parent().add_child(exp)
	exp.global_transform = global_transform

func stabilize_muzzle():
	muzzle.global_position.y = global_position.y + 0.5
	muzzle.global_position.x = global_position.x
	muzzle.global_position.z = global_position.z
	
func process_flipped(delta):
	pass
	
func on_accelerate():
	engine_force = engine_force_value
	brake = 0.0
	reversing = false
	
func on_brake():
	if current_speed > 0.5:
		brake = brake_force_value 
		engine_force = 0.0
		reversing = false
	elif reversing:
		engine_force = -engine_force_value * 0.4
		brake = 0.0
		reversing = true
	else:
		reversing = true
		
func on_steer_left():
	steering = steer_angle
	
func on_steer_right():
	steering = -steer_angle
	
func add_controller(_controller: Controller):
	_controller.accelerate.connect(on_accelerate)
	_controller._brake.connect(on_brake)
	_controller.fire_weapon.connect(fire_weapon)
	_controller.steer_left.connect(on_steer_left)
	_controller.steer_right.connect(on_steer_right)
	_controller.car = self
	add_child(_controller)
