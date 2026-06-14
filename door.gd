@tool
extends Node2D

@export var linked_button: NodePath
@export var pair_name: String = "A":
	set(value):
		pair_name = value
		_update_label()

@onready var DO = $AudioStreamPlayer2D
@onready var anim = $AnimatedSprite2D
@onready var door_body = $DoorBody

var is_open = false

func _ready():
	_update_label()
	if Engine.is_editor_hint():
		return
	anim.play("IDLE")
	var button = get_node(linked_button)
	button.door_open.connect(_on_door_open)
	button.door_close.connect(_on_door_close)

func _update_label() -> void:
	if not is_inside_tree():
		return
	if has_node("Label"):
		$Label.text =  pair_name

func _on_door_open():
	if not is_open:
		DO.play()
		is_open = true
		door_body.get_node("CollisionShape2D").disabled = true
		anim.play("DOOROPEN")
		await anim.animation_finished
		anim.play("OPENIDLE")
		DO.stop()

func _on_door_close():
	if is_open:
		DO.play()
		is_open = false
		anim.play("DOORDOWN")
		await anim.animation_finished
		door_body.get_node("CollisionShape2D").disabled = false
		anim.play("IDLE")
		DO.stop()
