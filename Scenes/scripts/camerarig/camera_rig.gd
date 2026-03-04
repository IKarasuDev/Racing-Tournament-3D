extends Node3D

@export var target: Node3D
@export var follow_speed: float = 5.0

func _physics_process(delta):
	if not target:
		return
		
	global_transform = global_transform.interpolate_with(
		target.global_transform,
		follow_speed * delta
	)
