extends VehicleBody3D

@export var max_engine_force := 3000.0
@export var max_brake_force := 100.0
@export var max_steering_angle := 0.5

# mesh editable desde el inspector del VehicleBody3D
@export var car_mesh: Mesh:
	set(value):
		car_mesh = value
		if is_inside_tree():
			$CarMesh.mesh = value

@onready var fl = $FrontLeft
@onready var fr = $FrontRight
@onready var rl = $RearLeft
@onready var rr = $RearRight

@export var vehicle_id : int
@export var vehicle_name : String
@export var traction_type : String
@export var player_control := true

func _ready():
	if car_mesh:
		$CarMesh.mesh = car_mesh


func _physics_process(delta):
	if !player_control:
		return
	
	var forward_input = Input.get_axis("S", "W")
	var steer_input = Input.get_axis("D", "A")

	engine_force = forward_input * max_engine_force
	steering = steer_input * max_steering_angle

	brake = 0.0
	if Input.is_action_pressed("SpaceBar"):
		brake = max_brake_force
