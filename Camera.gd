@tool
extends Camera3D

@export var target: Node3D
@export var follow_speed := 12.0   # Higher = snappier
@export var rotation_speed := 8.0 # Higher = faster rotation
@export var offset := Vector3(-5, 11, -5)

var _last_target_transform: Transform3D

func _ready():
	_update_position(1.0)
	if Engine.is_editor_hint() and target:
		_last_target_transform = target.global_transform
		_update_look_at()


func _notification(what):
	if not Engine.is_editor_hint():
		return
	_update_position(1.0)

	if what == NOTIFICATION_TRANSFORM_CHANGED:
		# Camera moved in editor
		_update_look_at()


func _process(delta):
	if not Engine.is_editor_hint():
		return

	if not target:
		return
	_update_position(delta)

	# Detect if target moved
	if target.global_transform != _last_target_transform:
		_last_target_transform = target.global_transform
		_update_look_at()


func _update_look_at():
	if target:
		look_at(target.global_transform.origin, Vector3.UP)
		

func _update_position(delta):
	return
	if not target:
		return

	# Desired position behind the car
	var desired_pos = target.global_transform.origin + target.global_transform.basis * offset

	# Smooth position
	global_transform.origin = global_transform.origin.lerp(desired_pos, delta * follow_speed)

	# Smooth rotation to match car direction
	var desired_basis = target.global_transform.basis
	global_transform.basis = global_transform.basis.slerp(desired_basis, delta * rotation_speed)
