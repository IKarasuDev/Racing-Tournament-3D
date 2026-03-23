extends Node

signal race_started
signal race_finished(winner_id, loser_id, results)

var player_data
var ai_data

var start_time := 0.0
var finish_times = {} # {VehicleName}
var finished_order = []

func setup_race(player_info, ai_info):
	player_data = player_info
	ai_data = ai_info
	
	finish_times.clear()
	finished_order.clear()
	

func start_race():
	start_time = Time.get_ticks_msec() / 1000.0
	emit_signal("race_started")
	

func register_finish(vehicle):

	var vehicle_id = vehicle.vehicle_id

	if vehicle_id in finish_times:
		return

	var current_time = Time.get_ticks_msec() / 1000.0
	var race_time = current_time - start_time

	finish_times[vehicle_id] = race_time
	finished_order.append(vehicle_id)

	print(vehicle.vehicle_name, " finished in ", race_time)

	# 🔥 SI ES EL PRIMERO → resolver inmediatamente
	if finished_order.size() == 1:
		resolve_race_immediate()

func resolve_race_immediate():

	var winner_id = finished_order[0]

	var results = {
		"winner_time": finish_times[winner_id]
	}

	print("Winner ID:", winner_id)

	emit_signal("race_finished", winner_id, null, results)
