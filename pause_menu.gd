extends Control

@onready var resume_btn = $CanvasLayer/Resume
@onready var bgm_slider = $CanvasLayer/BGMSlider
@onready var sfx_slider = $CanvasLayer/SFXSlider
@onready var quit_btn = $CanvasLayer/Quit
@onready var canvas = $CanvasLayer

func _ready():
	canvas.hide()
	hide()  # visible = false 대신
	resume_btn.pressed.connect(_on_resume)
	quit_btn.pressed.connect(_on_quit)
	bgm_slider.value_changed.connect(_on_bgm_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	
	bgm_slider.min_value = 0.0
	bgm_slider.max_value = 1.0
	bgm_slider.step = 0.01
	bgm_slider.value = 1.0
	
	sfx_slider.min_value = 0.0
	sfx_slider.max_value = 1.0
	sfx_slider.step = 0.01
	sfx_slider.value = 1.0

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.is_action("ui_cancel"):
			if visible:
				_on_resume()
			else:
				_open()

func _open():
	visible = true
	canvas.show()
	get_tree().paused = true

func _on_resume():
	visible = false
	canvas.hide()
	get_tree().paused = false

func _on_bgm_changed(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), linear_to_db(value))

func _on_sfx_changed(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))

func open_menu():
	_open()

func _on_quit():
	get_tree().quit()

func _on_regame_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
