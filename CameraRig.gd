@tool
extends Node3D

@export var target: Node3D        # The car
@export var follow_speed := 6.0   # Higher = snappier
@export var rotation_speed := 4.0 # Higher = faster rotation
@export var offset := Vector3(-5, 11, -5)

		
func _ready():
	if Engine.is_editor_hint() and target:
		_update_position(1.0)


func _notification(what):
	if not Engine.is_editor_hint():
		return

	_update_position(1.0)
		

func _process(delta):
	if not target:
		return

	_update_position(delta)

func _update_position(delta):
	if not target:
		return

	# Desired position behind the car
	var desired_pos = target.global_transform.origin + target.global_transform.basis * offset
	if desired_pos.y < offset.y:
		desired_pos.y = offset.y
	# Smooth position
	global_transform.origin = global_transform.origin.lerp(desired_pos, delta * follow_speed)

	# Smooth rotation to match car direction
	var desired_basis = target.global_transform.basis
	global_transform.basis = global_transform.basis.slerp(desired_basis, delta * rotation_speed)
