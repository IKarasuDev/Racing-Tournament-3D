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

		var new_match = Match.new(p1, p2)
		first_round.append(new_match)

	rounds.append(first_round)


func report_player_win(player_id):

	var current_round = rounds[0]

	for m in current_round:

		var a_id = m.participant_a.data.id
		var b_id = m.participant_b.data.id

		if a_id == player_id:
			m.winner = m.participant_a
			return m

		if b_id == player_id:
			m.winner = m.participant_b
			return m

	return null
	

func simulate_remaining_matches():

	var current_round = rounds[0]

	for m in current_round:

		if m.winner != null:
			continue

		if randi() % 2 == 0:
			m.winner = m.participant_a
		else:
			m.winner = m.participant_b
			

func advance_round():

	var current_round = rounds[0]
	var winners: Array = []

	for m in current_round:
		winners.append(m.winner.data)

	var next_round: Array = []

	for i in range(0, winners.size(), 2):

		var p1 = Participant.new(winners[i])
		var p2 = Participant.new(winners[i + 1])

		next_round.append(Match.new(p1, p2))

	rounds.append(next_round)
