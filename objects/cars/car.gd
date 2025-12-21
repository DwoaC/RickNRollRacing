extends VehicleBody3D
class_name Car

@export var engine_force_value: float = 3000.0
@export var brake_force_value: float = 6000.0
@export var steer_angle: float = 0.5   # radians
@export var respawn_delay: float = 1.5

var live_engine_force = 0.0
var is_dead = false

@onready var wheels: Array[VehicleWheel3D]: 
	get:
		if wheels.is_empty():
			for child in get_children():
				if child is VehicleWheel3D:
					wheels.append(child)
		return wheels

var track: Track

var cross_two_thirds: bool = false
var cross_one_thrid: bool = false
var current_lap: int

@export var bullet_scene: PackedScene = preload("res://objects/bullets/bullet.tscn")
@onready var muzzle = $Muzzle
@export var explosion_scene: PackedScene = preload("res://objects/effects/car_explosion.tscn")
@onready var fire_timer: Timer = $FireTimeout

signal speed_updated(new_speed: float)
signal suspension_updated(values: Array[float])
signal lap_completed(car: Car)

@onready var initial_y = $WheelFrontLeft.position.y

var current_speed: float:
	get:
		return linear_velocity.dot(transform.basis.z)

func _physics_process(delta):
	if is_dead:
		return
	process_controls(delta)
	stabilize_muzzle()	
	process_suspension(delta)
	process_lap(delta)
	emit_updates()	
	
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
	var curve = track.main_path.curve
	var current_offset = curve.get_closest_offset(track.main_path.to_local(global_position))
	
	var respawn_pos = track.main_path.to_global(curve.sample_baked(current_offset - 5.0))
	
	var look_at_pos = track.main_path.to_global(curve.sample_baked(current_offset + 5.0))
	
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	global_position = respawn_pos
	look_at(look_at_pos, Vector3.UP, true)
	
	global_position.y += 1.0

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
	var current_rotation = muzzle.global_rotation
	muzzle.global_rotation.x = 0
	muzzle.global_rotation.z = 0
	muzzle.global_position.y = global_position.y + 0.5
