extends VehicleBody3D

@export var max_engine_force := 3000.0
@export var max_brake_force := 100.0
@export var max_steering_angle := 0.5

func _physics_process(delta):
	var forward_input = Input.get_axis("S", "W")
	var steer_input = Input.get_axis("D", "A")

	engine_force = forward_input * max_engine_force
	steering = steer_input * max_steering_angle
	
	brake = 0.0
	if Input.is_action_pressed("SpaceBar"):
		brake = max_brake_force
