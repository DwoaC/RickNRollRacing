class_name Track
extends Node3D

@export var main_path: Path3D
@export var spawn_index: int = 0
@export var n_starting_columns = 2
var startline_scene = preload("res://tracks/startline.tscn")
var startline: Node3D

func _ready() -> void:
	place_startline()

func place_startline():
	startline = startline_scene.instantiate()
	place_node(startline)
	startline.rotation.x = 90
	add_child(startline)

var first_point_global: Vector3:
	get:
		return main_path.to_global(main_path.curve.get_point_position(spawn_index))

var second_point_global: Vector3:
	get:
		return main_path.to_global(main_path.curve.get_point_position(spawn_index + 1))

var is_repeatable: bool:
	get:
		return $Track/TrackCrossSection.path_joined

func get_spawn_transform() -> Transform3D:
	if not main_path:
		push_error("Main path not assigned on track!")
		return global_transform
		
	var curve = main_path.curve
	var local_pos = curve.get_point_position(spawn_index)
	var global_pos = main_path.to_global(local_pos)
	
	# To get the rotation, we look at the point slightly ahead
	var next_pos_local = curve.get_point_position(spawn_index + 1)
	var next_pos_global = main_path.to_global(next_pos_local)
	
	# Create a transform looking down the track
	var t = Transform3D()
	t = t.looking_at(next_pos_global - global_pos, Vector3.UP)
	t.origin = global_pos + Vector3(0, 0.5, 0) # Slight air gap
	return t

func place_node(node: Node3D):
	var curve = main_path.curve
	node.global_position = first_point_global
	node.look_at(second_point_global, Vector3.UP, true)
