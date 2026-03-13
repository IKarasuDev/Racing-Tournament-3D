extends Control

signal vehicles_ready(player_scene, player_name, player_id, opponent_scene, opponent_name, opponent_id)

@export var vehicles: Array[PackedScene]

var current_index := 0
var current_vehicle_instance: Node3D
var ai_vehicle_instance: Node3D
var ai_locked := false

@onready var player_preview_root = $HBoxContainer/PlayerSection/VBoxContainer/VehiclePreview/SubViewport/PlayerPreviewRoot
@onready var player_name_label = $HBoxContainer/PlayerSection/VBoxContainer/VehicleName
@onready var player_traction_label = $HBoxContainer/PlayerSection/VBoxContainer/TractionType

@onready var ai_preview_root = $HBoxContainer/IASection/VBoxContainer/SubViewportContainer/SubViewport/AIPreviewRoot
@onready var ai_name_label = $HBoxContainer/IASection/VBoxContainer/AIVehicleName
@onready var ai_traction_label = $HBoxContainer/IASection/VBoxContainer/AITractionType

#Buttons
@onready var next_button = $HBoxContainer/PlayerSection/VBoxContainer/HBoxContainer/RightButton
@onready var previous_button = $HBoxContainer/PlayerSection/VBoxContainer/HBoxContainer/LeftButton
@onready var select_button = $HBoxContainer/PlayerSection/VBoxContainer/HBoxContainer/SelectButton

var selected_vehicle_scene: PackedScene
var opponent_vehicle_scene: PackedScene


func _ready():
	randomize()
	show_player_vehicle(current_index)

	vehicles_ready.connect(_on_vehicles_ready)

# PLAYER CAROUSEL
func show_player_vehicle(index):

	if current_vehicle_instance:
		current_vehicle_instance.queue_free()

	var vehicle_scene = vehicles[index]
	current_vehicle_instance = vehicle_scene.instantiate()

	player_preview_root.add_child(current_vehicle_instance)

	current_vehicle_instance.player_control = false
	current_vehicle_instance.position = Vector3.ZERO
	current_vehicle_instance.rotation = Vector3(0, deg_to_rad(180), 0)

	update_player_labels()


func update_player_labels():

	player_name_label.text = current_vehicle_instance.vehicle_name
	player_traction_label.text = "Traction: " + current_vehicle_instance.traction_type


func next_vehicle():

	current_index += 1
	if current_index >= vehicles.size():
		current_index = 0

	show_player_vehicle(current_index)


func previous_vehicle():

	current_index -= 1
	if current_index < 0:
		current_index = vehicles.size() - 1

	show_player_vehicle(current_index)

# AI SELECTION

func generate_ai_vehicle():

	if ai_locked:
		return

	var player_id = current_vehicle_instance.vehicle_id
	var available: Array[PackedScene] = []

	for v in vehicles:

		var temp = v.instantiate()
		var id = temp.vehicle_id
		temp.queue_free()

		if id != player_id:
			available.append(v)

	if available.is_empty():
		return

	var random_index = randi() % available.size()
	opponent_vehicle_scene = available[random_index]

	ai_locked = true

	spin_ai_selection(available)


func spin_ai_selection(available):
	await spin_through_cars(available)
	show_ai_vehicle(opponent_vehicle_scene)
	check_vehicles_ready()

func spin_through_cars(available):
	for v in available:
		show_ai_vehicle(v)
		await get_tree().create_timer(0.15).timeout

func show_ai_vehicle(scene):

	if ai_vehicle_instance:
		ai_vehicle_instance.queue_free()

	ai_vehicle_instance = scene.instantiate()

	ai_preview_root.add_child(ai_vehicle_instance)

	ai_vehicle_instance.player_control = false
	ai_vehicle_instance.position = Vector3.ZERO
	ai_vehicle_instance.rotation = Vector3(0, deg_to_rad(180), 0)

	ai_name_label.text = ai_vehicle_instance.vehicle_name
	ai_traction_label.text = "Traction: " + ai_vehicle_instance.traction_type


# CONFIRM SELECTION

func select_vehicle():

	selected_vehicle_scene = vehicles[current_index]

	next_button.disabled = true
	previous_button.disabled = true
	select_button.disabled = true

	generate_ai_vehicle()

#Checking Cars
func _on_vehicles_ready(player_scene, player_name, player_id, opponent_scene, opponent_name, opponent_id):

	print("---- VEHICLES READY ----")

	print("Player Scene: ", player_scene)
	print("Player Name: ", player_name)
	print("Player ID: ", player_id)

	print("Opponent Scene: ", opponent_scene)
	print("Opponent Name: ", opponent_name)
	print("Opponent ID: ", opponent_id)

	print("------------------------")

func check_vehicles_ready():

	if selected_vehicle_scene == null or opponent_vehicle_scene == null:
		return

	var player_temp = selected_vehicle_scene.instantiate()
	var opponent_temp = opponent_vehicle_scene.instantiate()

	var player_name = player_temp.vehicle_name
	var player_id = player_temp.vehicle_id

	var opponent_name = opponent_temp.vehicle_name
	var opponent_id = opponent_temp.vehicle_id

	player_temp.queue_free()
	opponent_temp.queue_free()

	emit_signal(
		"vehicles_ready",
		selected_vehicle_scene,
		player_name,
		player_id,
		opponent_vehicle_scene,
		opponent_name,
		opponent_id
	)
