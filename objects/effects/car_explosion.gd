extends GPUParticles3D

@onready var explosion_sound: AudioStreamPlayer3D = $AudioStreamPlayer3D

func _ready():
	lifetime = explosion_sound.stream.get_length()
	emitting = true
	await get_tree().create_timer(lifetime).timeout
	queue_free()
