extends Node

@onready var player = $AudioStreamPlayer

var playlist = [
	preload("res://Scenes/Tools/Music/themes/GET ME POWER.mp3"),
	preload("res://Scenes/Tools/Music/themes/MAX COVERI  RUNNING IN THE 90'sOfficial Lyric Video.mp3"),
	preload("res://Scenes/Tools/Music/themes/SPACE BOY.mp3")
]

var current_track = 0

func _ready():
	player.finished.connect(_on_song_finished)
	play_current_song()

func play_current_song():
	player.stream = playlist[current_track]
	player.play()

func _on_song_finished():
	current_track += 1
	if current_track >= playlist.size():
		current_track = 0  # loop
	
	play_current_song()
