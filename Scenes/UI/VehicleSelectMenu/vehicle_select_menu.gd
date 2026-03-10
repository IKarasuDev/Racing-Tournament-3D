extends Control

@export var vehicles: Array[PackedScene]

var current_index := 0
var current_vehicle_instance: Node3D

@onready var preview_root = $CenterContainer/VBoxContainer/VehiclePreview/SubViewport/PreviewRoot
@onready var name_label = $CenterContainer/VBoxContainer/VehicleName
@onready var traction_label = $CenterContainer/VBoxContainer/TractionType

var selected_vehicle_scene: PackedScene

func _ready():
	show_vehicle(current_index)

func show_vehicle(index):

	if current_vehicle_instance:
		current_vehicle_instance.queue_free()

	var vehicle_scene = vehicles[index]
	current_vehicle_instance = vehicle_scene.instantiate()
	
	current_vehicle_instance = vehicle_scene.instantiate()

	preview_root.add_child(current_vehicle_instance)

	current_vehicle_instance.position = Vector3.ZERO
	current_vehicle_instance.rotation = Vector3(0, deg_to_rad(180), 0)

	update_labels()

func update_labels():
	name_label.text = current_vehicle_instance.vehicle_name
	traction_label.text = "Traction: " + current_vehicle_instance.traction_type
	
func next_vehicle():
	current_index += 1
	if current_index >= vehicles.size():
		current_index = 0
	show_vehicle(current_index)


func previous_vehicle():
	current_index -= 1
	if current_index < 0:
		current_index = vehicles.size() - 1
	show_vehicle(current_index)

func select_vehicle():
	selected_vehicle_scene = vehicles[current_index]
	print("Selected vehicle: ", selected_vehicle_scene)
