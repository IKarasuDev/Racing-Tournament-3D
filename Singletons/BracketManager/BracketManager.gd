class_name BracketManager
extends Node

var rounds: Array = []

# Estructuras internas
class Participant:
	var data
	
	func _init(_data):
		data = _data


class Match:
	var participant_a: Participant
	var participant_b: Participant
	var winner: Participant = null

	func _init(a, b):
		participant_a = a
		participant_b = b


# 🔥 Crear bracket inicial
func create_bracket(participants_data: Array):

	rounds.clear()

	var first_round: Array = []

	for i in range(0, participants_data.size(), 2):

		var p1 = Participant.new(participants_data[i])

		var p2 = Participant.new(participants_data[i + 1])

		var match = Match.new(p1, p2)
		first_round.append(match)

	rounds.append(first_round)
