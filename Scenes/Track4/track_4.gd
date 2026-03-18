extends Node3D

signal race_finished_signal(player_won)

@onready var finish_line = $DeckalFinish/FinishLine
@onready var race_timer = $RaceTimer
@onready var track_recorder = $TrackRecorder

@export var raceline_file := "user://track4_racing_line.json"
@export var enable_recording := false

var race_started := false
var race_finished := false
var race_just_started := false  # 🔥 FIX CLAVE

var player_vehicle
var ai_vehicle
var raceline_data = []


func _ready():

	if finish_line:
		finish_line.body_entered.connect(_on_finish_line_body_entered)

	if race_timer:
		race_timer.timeout.connect(_on_timer_unlock)

	RaceManager.race_finished.connect(_on_race_finished)

	# cargar raceline
	raceline_data = track_recorder.load_track(raceline_file)

	if raceline_data.is_empty():
		print("No raceline loaded for this track")
	else:
		print("Raceline loaded:", raceline_data.size(), "points")


func _on_finish_line_body_entered(body):

	if race_finished:
		return

	if !body.is_in_group("vehicle"):
		return

	# INICIO
	if !race_started and body.is_in_group("player"):
		start_race()
		return

	if race_just_started:
		return

	# 🔥 SI ES PLAYER → RESOLVER INMEDIATO
	if body.is_in_group("player"):
		RaceManager.register_player_finish(body)
	else:
		# IA solo registra tiempo
		RaceManager.register_finish(body)

func start_race():

	race_started = true
	race_just_started = true  # 🔥 activar bloqueo temporal

	print("Race Started")

	RaceManager.start_race()

	if enable_recording and track_recorder:
		track_recorder.start_recording()

	finish_line.monitoring = false
	race_timer.start()


func _on_timer_unlock():

	finish_line.monitoring = true
	race_just_started = false  # 🔥 ahora sí puede terminar

	print("Finish line unlocked")


func _on_race_finished(winner, loser, results):

	if race_finished:
		return

	race_finished = true

	var player_won = (winner != null and winner.is_in_group("player"))

	if player_won:
		print("Winner:", player_vehicle.name)
		show_result("Winner: " + player_vehicle.name, true)
	else:
		print("Loser:", player_vehicle.name)
		show_result("Loser: " + player_vehicle.name, false)

func show_result(text, player_won):

	var label = $UI/ResultLabel
	
	# asegurar estado inicial
	label.visible = false

	# ⏱️ esperar 1 segundo antes de mostrar
	await get_tree().create_timer(1.0).timeout

	label.text = text
	label.visible = true

	# ⏱️ esperar 2 segundos más antes de continuar
	await get_tree().create_timer(3.0).timeout

	if player_won:
		emit_signal("race_finished_signal", true)
	else:
		emit_signal("race_finished_signal", false)

func setup_race(player_scene, opponent_scene):

	var player_spawn = $PlayerSpawn
	var ai_spawn = $AISpawn

	player_vehicle = player_scene.instantiate()
	ai_vehicle = opponent_scene.instantiate()

	add_child(player_vehicle)
	add_child(ai_vehicle)

	# posiciones
	player_vehicle.global_position = player_spawn.global_position
	player_vehicle.global_rotation = player_spawn.global_rotation

	ai_vehicle.global_position = ai_spawn.global_position
	ai_vehicle.global_rotation = ai_spawn.global_rotation

	# control correcto
	player_vehicle.player_control = true
	player_vehicle.ai_control = false

	ai_vehicle.player_control = false
	ai_vehicle.ai_control = true

	# 🔥 GRUPOS (CLAVE para detección)
	player_vehicle.add_to_group("player")
	player_vehicle.add_to_group("vehicle")

	ai_vehicle.add_to_group("vehicle")

	# recorder (opcional)
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


func assign_camera(player_vehicle):

	var camera_rig = $CameraRig

	if camera_rig:
		camera_rig.target = player_vehicle
