extends Node

var bracket

var participants: Array = []
var all_vehicles: Array[PackedScene] = []

func start_tournament(player_data: Dictionary, vehicles: Array[PackedScene], opponent_data: Dictionary):

	all_vehicles = vehicles.duplicate()
	participants.clear()

	# 1. PLAYER
	participants.append(player_data)

	# 2. OPPONENT (FIJO contra el player)
	participants.append(opponent_data)

	# 3. GENERAR RESTO IA
	var available := []

	for v in all_vehicles:
		var temp = v.instantiate()

		if temp.vehicle_id != player_data.id and temp.vehicle_id != opponent_data.id:
			available.append(v)

		temp.queue_free()

	available.shuffle()

	var needed = 6

	for i in range(min(needed, available.size())):

		var temp = available[i].instantiate()

		participants.append({
			"scene": available[i],
			"name": temp.vehicle_name,
			"id": temp.vehicle_id
		})

		temp.queue_free()

	print("TOTAL VEHICLES:", all_vehicles.size())
	print("AVAILABLE:", available.size())
	print("PARTICIPANTS:", participants.size())

	# 🔥 IMPORTANTE: NO SHUFFLE AQUÍ

	bracket = BracketManager.new()
	bracket.create_bracket(participants)

func get_first_round():

	if bracket == null:
		return []

	return bracket.rounds[0]
