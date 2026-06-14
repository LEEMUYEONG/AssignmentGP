extends Control

@onready var new_game_btn = $CanvasLayer/NewGame
@onready var setting_btn = $CanvasLayer/Setting
@onready var pause_menu = $PauseMenu

func _ready():
	new_game_btn.pressed.connect(_on_new_game)
	setting_btn.pressed.connect(_on_setting)

func _on_new_game():
	get_tree().change_scene_to_file("res://stage_1.tscn")

func _on_setting():
	pause_menu.open_menu()
