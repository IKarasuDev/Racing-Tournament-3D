extends Control

@onready var labels = [
	$ColorRect/Column1/Slot1C1/P1, 
	$ColorRect/Column1/Slot2C1/P2, 
	$ColorRect/Column1/Slot3C1/P3,
	$ColorRect/Column1/Slot4C1/P4,
	$ColorRect/Column1/Slot5C1/P5,
	$ColorRect/Column1/Slot6C1/P6,
	$ColorRect/Column1/Slot7C1/P7,
	$ColorRect/Column1/Slot8C1/P8
]

func setup(bracket_round):

	var index = 0

	for match in bracket_round:

		labels[index].text = match.participant_a.data.name
		labels[index + 1].text = match.participant_b.data.name

		index += 2
