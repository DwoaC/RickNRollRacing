extends Node3D
class_name World

@export var track_path: String
@export var cars: Array[Car]
@export var n_ai: int = 0

var CAR_OFFSET_H = 2.0
var CAR_OFFSET_Z = 5.0
const AI_CAR_SCENE = preload("res://objects/cars/ai.tscn")
const AI_CAR_STATS = preload("res://resources/ai_stats.tres")

@onready var camera_rig: Node3D = $CameraRig

const track_folder = "res://tracks/"
var track: Track
var max_laps = INF

signal track_changed(track: Track)
signal max_laps_changed(max_laps)

func _ready() -> void:
	pass
	
func start():
	setup_signals()
	load_level()
	place_cars()

func place_cars():
	var index = 0
	for car in cars:
		place_car(car, index)
		index += 1

func setup_signals():
	for car in cars:
		track_changed.connect(car.on_track_changed)
	
	var all_car_guis = get_parent().find_children("*", "CarGUICanvas", true)
	
	for car_gui in all_car_guis:
		print("connecting " + str(car_gui))
		track_changed.connect(car_gui.on_track_changed)
		max_laps_changed.connect(car_gui.on_max_laps_changed)

func load_level():
	print("Loading " + track_path)
	var track_resource = load(track_path)
	
	if is_instance_valid(track):
		track.queue_free()
		remove_child(track) 
	
	track = track_resource.instantiate()
	add_child(track)
	
	track_changed.emit(track)
	max_laps_changed.emit(max_laps)

func place_car(car, position):
	if car and track:
		var curve = track.main_path.curve
		
		car.global_position = track.first_point_global
		car.global_position.y += 2
		car.look_at(track.second_point_global, Vector3.UP, true)
		
		car.linear_velocity = Vector3.ZERO
		car.angular_velocity = Vector3.ZERO
		
		var h_offset = position % track.n_starting_columns
		var z_offset = position / track.n_starting_columns
		
		var right_direction = car.global_transform.basis.x
		var back_direction = -car.global_transform.basis.z
		
		car.global_position -= right_direction * CAR_OFFSET_H	

		car.global_position += right_direction * CAR_OFFSET_H * h_offset * 2		
		car.global_position += back_direction * CAR_OFFSET_Z * z_offset
