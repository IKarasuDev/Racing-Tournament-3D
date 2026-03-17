extends Node

@export var player: VehicleBody3D
@export var record_interval := 0.1
@export var save_path := "user://track2_racing_line.json"

var recording := false
var timer := 0.0
var recorded_points: Array = []


func start_recording():

	recorded_points.clear()
	recording = true
	timer = 0.0

	print("Track recording started")


func stop_recording():

	recording = false
	print("Track recording stopped")


func _process(delta):

	if !recording or player == null:
		return

	timer += delta

	if timer < record_interval:
		return

	timer = 0

	var p = player.global_position
	var speed = player.linear_velocity.length()

	var data = {
		"x": p.x,
		"y": p.y,
		"z": p.z,
		"speed": speed,
	}

	recorded_points.append(data)


func save_track():

	if recorded_points.is_empty():
		print("No points recorded")
		return

	var json_string = JSON.stringify(recorded_points, "\t")

	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(json_string)

	print("Track saved:", recorded_points.size(), "points")
	print(ProjectSettings.globalize_path(save_path))


func load_track(path: String):

	if !FileAccess.file_exists(path):
		print("Track not found:", path)
		return []

	var file = FileAccess.open(path, FileAccess.READ)
	var json_text = file.get_as_text()

	var data = JSON.parse_string(json_text)

	if data == null:
		print("JSON parse error")
		return []

	return data
