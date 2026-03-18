extends Node

var player_scene: PackedScene
var opponent_scene: PackedScene

@onready var scene_container = $SceneContainer
@onready var transition = $Transition

var tournament_controller
var vehicles_cache: Array

var tracks = [
	"res://Scenes/Track1/track_1.tscn",
	"res://Scenes/Track2/track_2.tscn",
	"res://Scenes/Track3/track_3.tscn",
	"res://Scenes/Track4/track_4.tscn"
]

var current_track_index := 0


func _ready():
	load_vehicle_selection()

func load_vehicle_selection():

	var selection_scene = load("res://Scenes/UI/VehicleSelectMenu/vehicle_select_menu.tscn").instantiate()
	scene_container.add_child(selection_scene)

	vehicles_cache = selection_scene.vehicles

	selection_scene.vehicles_ready.connect(_on_vehicles_ready)

func _on_vehicles_ready(player_sc, player_name, player_id, opponent_sc, opponent_name, opponent_id):

	tournament_controller = load("res://Singletons/TournamentController/TournamentController.gd").new()

	var player_data = {
		"scene": player_sc,
		"name": player_name,
		"id": player_id
	}

	var opponent_data = {
		"scene": opponent_sc,
		"name": opponent_name,
		"id": opponent_id
	}

	tournament_controller.start_tournament(player_data, vehicles_cache, opponent_data)

	await get_tree().create_timer(2.0).timeout

	await transition.fade_in(1.0)

	show_bracket()

	await transition.fade_out(1.0)

func show_bracket():

	for c in scene_container.get_children():
		c.queue_free()

	var bracket_scene = load("res://Scenes/UI/BracketLayout/bracket_layout.tscn").instantiate()
	scene_container.add_child(bracket_scene)

	var first_round = tournament_controller.get_first_round()

	bracket_scene.setup(first_round)


func start_race():

	await get_tree().create_timer(1.5).timeout
	await transition.fade_in(1.5)

	load_track()

	await transition.fade_out(1.0)


func load_track():

	# limpiar escena actual
	for c in scene_container.get_children():
		c.queue_free()

	# verificar si hay más pistas
	if current_track_index >= tracks.size():
		print("Tournament finished")
		return

	var track_path = tracks[current_track_index]
	var track = load(track_path).instantiate()

	scene_container.add_child(track)

	# conectar señal de fin de carrera
	if track.has_signal("race_finished_signal"):
		track.race_finished_signal.connect(_on_race_finished)

	# enviar autos
	track.setup_race(player_scene, opponent_scene)


func _on_race_finished(player_won):

	print("Track finished:", current_track_index)

	if player_won:
		current_track_index += 1

		await transition.fade_in(1.5)
		load_track()
		await transition.fade_out(1.0)
	else:
		# 🔥 derrota → volver al menú
		await transition.fade_in(1.5)

		current_track_index = 0
		load_vehicle_selection()

		await transition.fade_out(1.0)

func show_result(text, player_won):

	var label = $UI/ResultLabel
	label.text = text
	label.visible = true

	await get_tree().create_timer(3.0).timeout

	if player_won:
		emit_signal("race_finished_signal", true)
	else:
		emit_signal("race_finished_signal", false)
