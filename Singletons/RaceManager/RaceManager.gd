extends Node

signal race_started
signal race_finished(winner, loser, results)

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
	#Evitar duplicados
	if vehicle in finish_times:
		return
	
	var current_time = Time.get_ticks_msec() / 1000
	var race_time = current_time - start_time
	
	finish_times[vehicle] = race_time
	finished_order.append(vehicle)
	
	print(vehicle.name, " finished in ", race_time)
	
	if finished_order.size() == 2:
		resolve_race()
		

func resolve_race():
	var winner = finished_order[0]
	var loser = finished_order[1]
	
	var results = {
		"winner_timer": finish_times[winner],
		"loser_time": finish_times[loser]
	}
	
	print("Winner: ", winner.name)
	
	emit_signal("race_finished", winner, loser, results)
