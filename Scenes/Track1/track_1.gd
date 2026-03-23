extends Node3D

signal race_finished_signal(player_won)

@onready var finish_line = $DeckalFinish/FinishLine
@onready var checkpoint = $Checkpoint
@onready var track_recorder = $TrackRecorder

@export var raceline_file := "user://track1_racing_line.json"
@export var enable_recording := false

var race_started := false
var race_finished := false

var player_vehicle
var ai_vehicle
var raceline_data = []

var can_finish := false 


func _ready():

	if finish_line and not finish_line.body_entered.is_connected(_on_finish_line_body_entered):
		finish_line.body_entered.connect(_on_finish_line_body_entered)

	if checkpoint and not checkpoint.body_entered.is_connected(_on_checkpoint_body_entered):
		checkpoint.body_entered.connect(_on_checkpoint_body_entered)

	RaceManager.race_finished.connect(_on_race_finished)

	# cargar raceline
	raceline_data = track_recorder.load_track(raceline_file)

	if raceline_data.is_empty():
		print("No raceline loaded for this track")
	else:
		print("Raceline loaded:", raceline_data.size(), "points")


# =========================
# CHECKPOINT (CLAVE)
# =========================
func _on_checkpoint_body_entered(body):

	if !race_started:
		return

	if !body.is_in_group("vehicle"):
		return

	# puedes hacerlo solo para player si quieres
	if body.is_in_group("vehicle"):
		can_finish = true
		print("Checkpoint passed → can_finish = true")


# =========================
# FINISH LINE
# =========================
func _on_finish_line_body_entered(body):

	if race_finished:
		return

	if !body.is_in_group("vehicle"):
		return

	# START DE LA CARRERA
	if !race_started and body.is_in_group("player"):
		start_race()
		return

	# 🔥 VALIDACIÓN REAL
	if !can_finish:
		print("Finish blocked (no checkpoint)")
		return

	# FIN
	if body.is_in_group("vehicle"):
		RaceManager.register_finish(body)
	else:
		RaceManager.register_finish(body)


# =========================
# START
# =========================
func start_race():

	race_started = true
	can_finish = false  # 🔥 reset obligatorio

	print("Race Started")

	RaceManager.start_race()

	if enable_recording and track_recorder:
		track_recorder.start_recording()


# =========================
# RESULTADO
# =========================
func _on_race_finished(winner, _loser, _results):

	if race_finished:
		return

	race_finished = true

	var player_won = (winner != null and winner == player_vehicle.vehicle_id)

	if player_won:
		print("Winner:", player_vehicle.name)
		show_result("Winner: " + player_vehicle.vehicle_name, true)
	else:
		print("Loser:", player_vehicle.name)
		show_result("Loser: " + player_vehicle.vehicle_name, false)


func show_result(text, player_won):

	var label = $UI/ResultLabel
	
	label.visible = false

	await get_tree().create_timer(0.5).timeout

	label.text = text
	label.visible = true

	await get_tree().create_timer(3.0).timeout

	emit_signal("race_finished_signal", player_won)


# =========================
# SETUP RACE
# =========================
func setup_race(player_scene, opponent_scene):

	var player_spawn = $PlayerSpawn
	var ai_spawn = $AISpawn

	# instanciar primero
	player_vehicle = player_scene.instantiate()
	ai_vehicle = opponent_scene.instantiate()

	add_child(player_vehicle)
	add_child(ai_vehicle)

	# 🔥 ahora sí setup correcto
	RaceManager.setup_race(
		player_vehicle.vehicle_id,
		ai_vehicle.vehicle_id
	)

	# posiciones
	player_vehicle.global_position = player_spawn.global_position
	player_vehicle.global_rotation = player_spawn.global_rotation

	ai_vehicle.global_position = ai_spawn.global_position
	ai_vehicle.global_rotation = ai_spawn.global_rotation

	# control
	player_vehicle.player_control = true
	player_vehicle.ai_control = false

	ai_vehicle.player_control = false
	ai_vehicle.ai_control = true

	# grupos
	player_vehicle.add_to_group("player")
	player_vehicle.add_to_group("vehicle")

	ai_vehicle.add_to_group("vehicle")

	# recorder
	if track_recorder:
		track_recorder.player = player_vehicle
		track_recorder.save_path = raceline_file

	# IA raceline
	if raceline_data.size() > 0:
		if ai_vehicle.has_method("set_raceline"):
			ai_vehicle.set_raceline(raceline_data)
		else:
			print("AI vehicle missing set_raceline()")
	else:
		print("No raceline available for AI")

	assign_camera(player_vehicle)


# =========================
# CAMERA
# =========================
func assign_camera(target_vehicle):

	var camera_rig = $CameraRig

	if camera_rig:
		camera_rig.target = target_vehicle
