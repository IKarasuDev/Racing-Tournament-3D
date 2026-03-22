extends Control

@onready var column1 = [
	$ColorRect/Column1/Slot1C1/P1, 
	$ColorRect/Column1/Slot2C1/P2, 
	$ColorRect/Column1/Slot3C1/P3,
	$ColorRect/Column1/Slot4C1/P4,
	$ColorRect/Column1/Slot5C1/P5,
	$ColorRect/Column1/Slot6C1/P6,
	$ColorRect/Column1/Slot7C1/P7,
	$ColorRect/Column1/Slot8C1/P8
]

@onready var column2 = [
	$ColorRect/Column2/Slot1/P1C2,
	$ColorRect/Column2/Slot2/P2C2,
	$ColorRect/Column2/Slot3/P3C2,
	$ColorRect/Column2/Slot4/P4C2
]

@onready var column3 = [
	$ColorRect/Column3/ColorRect/P1C3,
	$ColorRect/Column3/Slot6/P2C3
]

@onready var column4 = [
	$ColorRect/Column4/Slot5/Champion
]

func setup(rounds):

	# -------- ROUND 1 (columna 1) --------
	var r1 = rounds[0]
	var index = 0

	for match in r1:
		column1[index].text = match.participant_a.data.name
		column1[index + 1].text = match.participant_b.data.name
		index += 2

	# -------- ROUND 2 (columna 2) --------
	if rounds.size() > 1:
		var r2 = rounds[1]
		index = 0

		for match in r2:
			if match.participant_a:
				column2[index].text = match.participant_a.data.name
			if match.participant_b:
				column2[index + 1].text = match.participant_b.data.name
			index += 2

	# -------- FINAL (columna 3) --------
	if rounds.size() > 2:
		var r3 = rounds[2]

		column3[0].text = r3[0].participant_a.data.name
		column3[1].text = r3[0].participant_b.data.name
		
	# -------- CAMPEÓN (columna 4) --------
	if rounds.size() > 2:

		var final_round = rounds[2]

		if final_round.size() > 0:
			var final_match = final_round[0]

			if final_match.winner != null:
				column4[0].text = final_match.winner.data.name
			else:
				column4[0].text = "TBD"
