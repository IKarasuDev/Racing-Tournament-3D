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
	start_time = Time.get_ticks_msec() / 1000
	emit_signal("race_started")
	

func register_finish(vehicle):

	var vehicle_id = vehicle.vehicle_id

	if vehicle_id in finish_times:
		return

	var current_time = Time.get_ticks_msec() / 1000
	var race_time = current_time - start_time

	finish_times[vehicle_id] = race_time
	finished_order.append(vehicle_id)

	print(vehicle.name, " finished in ", race_time)

	if finished_order.size() == 2:
		resolve_race()


func resolve_race():

	var winner_id = finished_order[0]
	var loser_id = finished_order[1]

	var results = {
		"winner_time": finish_times[winner_id],
		"loser_time": finish_times[loser_id]
	}

	print("Winner ID: ", winner_id)

	emit_signal("race_finished", winner_id, loser_id, results)

func register_player_finish(vehicle):

	register_finish(vehicle)

	var vehicle_id = vehicle.vehicle_id

	var winner_id
	var loser_id

	if finished_order.size() == 1:
		winner_id = vehicle_id
		loser_id = null
	else:
		winner_id = finished_order[0]
		loser_id = vehicle_id

	var results = {
		"player_time": finish_times[vehicle_id],
		"winner_time": finish_times.get(winner_id, 0.0)
	}

	emit_signal("race_finished", winner_id, loser_id, results)
