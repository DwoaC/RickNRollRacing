class_name Whiskers
extends Node3D

@export var distance = 1
@export var dis_scale = 0.05

func _process(_delta):
	update_position()
	global_rotation.x = 0 
	global_rotation.z = 0
	
func update_position():
	var size = 0.5 + distance / 40
	$Left.target_position = distance * dis_scale * Vector3(-1, 0, 5).normalized()
	$Left.shape.size.x = size
	$Forward.target_position = distance * dis_scale  * Vector3(0, 0, 5).normalized()
	$Forward.shape.size.x = size
	$Right.target_position = distance * dis_scale * Vector3(1, 0, 5).normalized()
	$Right.shape.size.x = size
	
	for ray_cast in get_children():
		if ray_cast is RayCast3D:
			for mesh in ray_cast.get_children():
				mesh.position = ray_cast.target_position
