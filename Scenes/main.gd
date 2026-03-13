extends Node

var player_scene: PackedScene
var opponent_scene: PackedScene

@onready var scene_container = $SceneContainer
@onready var transition = $Transition


func _ready():
	load_vehicle_selection()


func load_vehicle_selection():

	var selection_scene = load("res://Scenes/UI/VehicleSelectMenu/vehicle_select_menu.tscn").instantiate()

	scene_container.add_child(selection_scene)

	selection_scene.vehicles_ready.connect(_on_vehicles_ready)


func _on_vehicles_ready(player_sc, player_name, player_id, opponent_sc, opponent_name, opponent_id):

	player_scene = player_sc
	opponent_scene = opponent_sc

	print("Loading Track 1...")

	start_race()

func start_race():
	# tiempo para que el jugador vea el oponente
	await get_tree().create_timer(2).timeout

	await transition.fade_in(2.0)

	load_track()

	await transition.fade_out(1.5)

func load_track():
	for c in scene_container.get_children():
		c.queue_free()

	var track = load("res://Scenes/track_1.tscn").instantiate()

	scene_container.add_child(track)

	spawn_vehicles(track)


func spawn_vehicles(track):

	var player_spawn = track.get_node("PlayerSpawn")
	var ai_spawn = track.get_node("AISpawn")

	var player_vehicle = player_scene.instantiate()
	var ai_vehicle = opponent_scene.instantiate()

	track.add_child(player_vehicle)
	track.add_child(ai_vehicle)

	player_vehicle.global_position = player_spawn.global_position
	player_vehicle.global_rotation = player_spawn.global_rotation

	ai_vehicle.global_position = ai_spawn.global_position
	ai_vehicle.global_rotation = ai_spawn.global_rotation

	player_vehicle.player_control = true
	ai_vehicle.player_control = false

	assign_camera_target(track, player_vehicle)
	

func assign_camera_target(track, player_vehicle):

	var camera_rig = track.get_node("CameraRig")

	if camera_rig:
		camera_rig.target = player_vehicle

func play_transition():
	await transition.fade_in(2.0)
	await transition.fade_out(1.5)
