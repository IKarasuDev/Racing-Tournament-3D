extends VehicleBody3D

@export var max_engine_force := 3000.0
@export var max_brake_force := 100.0
@export var max_steering_angle := 0.5
var brake_timer := 0.0
var brake_duration := 0.6

@export var car_mesh: Mesh:
	set(value):
		car_mesh = value
		if is_inside_tree():
			$CarMesh.mesh = value


@onready var fl = $FrontLeft
@onready var fr = $FrontRight
@onready var rl = $RearLeft
@onready var rr = $RearRight

@onready var engine_sound = $AudioStreamPlayer3D


@export var vehicle_id : int
@export var vehicle_name : String
@export var traction_type : String


# CONTROL MODES
@export var player_control := true

@export var ai_control := false:
	set(value):
		ai_control = value
		if value:
			print("AI mode enabled for:", vehicle_name)


# IA TRACK
@export var track_file := "user://track1_racing_line.json"

var racing_line = []
var current_point := 0

func _ready():
	engine_sound.play()

	if car_mesh:
		$CarMesh.mesh = car_mesh

	print("Vehicle ready:", vehicle_name)
	print("Player control:", player_control)
	print("AI control:", ai_control)


func load_track():

	print("AI trying to load track:", track_file)

	if !FileAccess.file_exists(track_file):
		print("Track file not found")
		return

	var file = FileAccess.open(track_file, FileAccess.READ)
	var json_text = file.get_as_text()

	racing_line = JSON.parse_string(json_text)

	if racing_line == null:
		print("JSON parse failed")
		return

	print("AI loaded points:", racing_line.size())

	find_closest_point()


func find_closest_point():

	var closest_dist := INF
	var closest_index := 0

	for i in racing_line.size():

		var p = racing_line[i]
		var pos = Vector3(p["x"], p["y"], p["z"]) 

		var d = global_position.distance_to(pos)

		if d < closest_dist:
			closest_dist = d
			closest_index = i

	current_point = closest_index

	print("AI starting at point:", current_point)


func _physics_process(_delta):

	if player_control:
		player_drive()

	elif ai_control:

		if racing_line.is_empty():
			return

		ai_drive()


func player_drive():

	var forward_input = Input.get_axis("S", "W")
	var steer_input = Input.get_axis("D", "A")

	engine_force = forward_input * max_engine_force
	steering = steer_input * max_steering_angle

	brake = 0.0
	if Input.is_action_pressed("SpaceBar"):
		brake = max_brake_force


func ai_drive():

	var speed = linear_velocity.length()

	# LOOKAHEAD dinámico
	var lookahead := 8
	if speed > 20:
		lookahead = 15
	if speed > 40:
		lookahead = 25
	if speed > 60:
		lookahead = 35

	var target_index = (current_point + lookahead) % racing_line.size()
	var point = racing_line[target_index]

	var target = Vector3(point["x"], point["y"], point["z"])

	var dir = target - global_position
	dir.y = 0

	if dir.length() < 20.0:
		current_point = (current_point + 1) % racing_line.size()

	dir = dir.normalized()

	var local_dir = transform.basis.inverse() * dir

	steering = clamp(local_dir.x * 1.4, -1.0, 1.0) * max_steering_angle


	# -------- DETECTAR ZONA DE FRENO --------

	var brake_ahead := false

	for i in range(0, 8):

		var idx = (target_index + i) % racing_line.size()
		var p = racing_line[idx]

		if p.has("brake") and p.brake:
			brake_ahead = true
			break


	if brake_ahead:
		brake_timer = brake_duration


	# -------- CONTROL DE VELOCIDAD --------

	var target_speed = point.speed

	if brake_timer > 0:

		brake_timer -= get_physics_process_delta_time()

		engine_force = 0
		brake = max_brake_force

	else:

		if speed < target_speed:

			engine_force = max_engine_force
			brake = 0

		else:

			engine_force = 0
			brake = max_brake_force * 0.3


	# -------- RECOVERY SI SE ATORA --------

	if speed < 1.5:
		engine_force = max_engine_force * 0.4
		steering = -steering

func set_raceline(data):

	racing_line = data

	if racing_line.is_empty():
		print("Received empty raceline")
		return

	print("AI received raceline:", racing_line.size(), "points")

	find_closest_point()
