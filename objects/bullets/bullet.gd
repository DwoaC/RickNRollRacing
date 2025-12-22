class_name Bullet
extends Area3D

@export var speed: float = 150.0
@export var damage: int = 1
@export var life_time: float = 10.0 # Seconds before the bullet disappears
var source: Car
@onready var self_collision_timer: Timer = %Timer

func _ready():
	get_tree().create_timer(life_time).timeout.connect(queue_free)
	body_entered.connect(_on_body_entered)
	
func _physics_process(delta):
	position += global_transform.basis.z * speed * delta

func _on_body_entered(body):
	if not self_collision_timer.is_stopped():
		if body==source:
			return
			
	if body.has_method("take_damage"):
		body.take_damage(damage, source)
	queue_free()
