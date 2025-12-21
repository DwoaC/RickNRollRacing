extends Node3D

@export var track_path: String = "res://tracks/track_1.tscn"

@onready var car: Car = $Player
@onready var camera_rig: Node3D = $CameraRig

const track_folder = "res://tracks/"
var track: Track
var max_laps = INF

signal track_changed(track: Track)
signal max_laps_changed(max_laps)


func _ready() -> void:
	track_changed.connect(car.on_track_changed)
	track_changed.connect($CanvasLayer/CarGUI.on_track_changed)
	max_laps_changed.connect($CanvasLayer/CarGUI.on_max_laps_changed)
	
	load_level()
	place_car()

func load_level():
	var track_resource = load(track_path)
	
	if is_instance_valid(track):
		track.queue_free()
		remove_child(track) 
	
	track = track_resource.instantiate()
	add_child(track)
	
	track_changed.emit(track)
	max_laps_changed.emit(max_laps)

func place_car():
	if car and track:
		var curve = track.main_path.curve
		
		car.global_position = track.first_point_global
		car.look_at(track.second_point_global, Vector3.UP, true)
		
		car.linear_velocity = Vector3.ZERO
		car.angular_velocity = Vector3.ZERO
		
		print(str(track.first_point_global) + "->" + str(track.second_point_global))
