extends Control

signal restart_pressed
signal exit_pressed

@onready var restart_button = $VBoxContainer/Restart
@onready var exit_button =$VBoxContainer/Exit

func _ready():
	restart_button.pressed.connect(_on_restart_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func show_menu():
	visible = true
	get_tree().paused = true

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
	emit_signal("restart_pressed")

func _on_exit_pressed():
	get_tree().paused = false
	
	if OS.has_feature("web"):
		# En navegador no se puede cerrar la pestaña
		get_tree().reload_current_scene()
	else:
		get_tree().quit()
	
	emit_signal("exit_pressed")
