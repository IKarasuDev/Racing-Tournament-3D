extends Node3D

@onready var finish_line = $DeckalFinish/FinishLine
@onready var race_timer = $RaceTimer
@onready var track_recorder = $TrackRecorder

var race_started := false
var race_finished := false


func _ready():

	if finish_line:
		finish_line.body_entered.connect(_on_finish_line_body_entered)

	if race_timer:
		race_timer.timeout.connect(_on_timer_unlock)


func _on_finish_line_body_entered(body):

	if race_finished:
		return

	if !body.is_in_group("player"):
		return

	# PRIMER PASO -> INICIO
	if !race_started:
		start_race()
		return

	# SEGUNDO PASO -> FINAL
	finish_race()


func start_race():

	race_started = true

	print("Race Started")

	if track_recorder:
		track_recorder.start_recording()

	finish_line.monitoring = false
	race_timer.start()


func finish_race():

	race_finished = true

	print("Race Finished")

	if track_recorder:
		track_recorder.stop_recording()
		track_recorder.save_track()


func _on_timer_unlock():

	finish_line.monitoring = true
	print("Finish line unlocked")
