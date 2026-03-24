extends Node

var player_scene: PackedScene
var opponent_scene: PackedScene

@onready var scene_container = $SceneContainer
@onready var transition = $Transition
@onready var Music = $AudioStreamPlayer

var tournament_controller
var vehicles_cache: Array

var tracks = [
	"res://Scenes/Track1/track_1.tscn",
	"res://Scenes/Track2/track_2.tscn",
	"res://Scenes/Track4/track_4.tscn"
]

var current_track_index := 0
var tournament_finished := false

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

func show_bracket(start_next_race := true):
	if tournament_controller == null or tournament_controller.bracket == null:
		return

	for c in scene_container.get_children():
		c.queue_free()

	var bracket_scene = load("res://Scenes/UI/BracketLayout/bracket_layout.tscn").instantiate()
	scene_container.add_child(bracket_scene)

	var rounds = tournament_controller.bracket.rounds
	bracket_scene.setup(rounds)
	
	if start_next_race:
		await get_tree().create_timer(3.0).timeout
		start_race()


func start_race():

	if tournament_controller == null or tournament_controller.bracket == null:
		return

	await get_tree().create_timer(1.5).timeout
	await transition.fade_in(1.5)

	load_track()

	await transition.fade_out(1.0)


func load_track():

	for c in scene_container.get_children():
		c.queue_free()

	if current_track_index >= tracks.size():

		if tournament_finished:
			return

		tournament_finished = true

		print("Tournament finished")

		show_bracket(false)
		
		await get_tree().create_timer(3.0).timeout
		
		show_end_menu()
		
		return

	var track_path = tracks[current_track_index]
	var track = load(track_path).instantiate()

	scene_container.add_child(track)

	if track.has_signal("race_finished_signal"):
		track.race_finished_signal.connect(_on_race_finished)

	var match = tournament_controller.get_player_match()

	if match == null:
		print("No player match found")
		return

	var player_data = match.participant_a.data
	var opponent_data = match.participant_b.data

	if player_data.id != tournament_controller.participants[0].id:
		var temp = player_data
		player_data = opponent_data
		opponent_data = temp

	player_scene = player_data.scene
	opponent_scene = opponent_data.scene

	track.setup_race(player_scene, opponent_scene)

func _on_race_finished(player_won):

	if player_won:

		current_track_index += 1
		tournament_controller.process_player_win()

		await transition.fade_in(1.5)
		show_bracket()
		await transition.fade_out(1.0)

		# se acaba el torneo
		if current_track_index >= tracks.size():
			return

	else:
		await transition.fade_in(1.5)

		tournament_controller.reset()
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

func show_end_menu():

	for c in scene_container.get_children():
		c.queue_free()

	var end_menu = load("res://Scenes/UI/EndMenu/end_menu.tscn").instantiate()
	scene_container.add_child(end_menu)

	end_menu.restart_pressed.connect(_on_restart_pressed)
	end_menu.exit_pressed.connect(_on_exit_pressed)

func _on_restart_pressed():

	await transition.fade_in(1.0)

	tournament_controller.reset()
	current_track_index = 0
	tournament_finished = false 

	load_vehicle_selection()

	await transition.fade_out(1.0)


func _on_exit_pressed():

	if OS.has_feature("web"):
		await _on_restart_pressed()
	else:
		get_tree().quit()
