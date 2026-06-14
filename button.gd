@tool
extends StaticBody2D

signal door_open
signal door_close

@export var pair_name: String = "A":
	set(value):
		pair_name = value
		_update_label()

@onready var Click = $AudioStreamPlayer2D
@onready var anim = $AnimatedSprite2D
@onready var detect_area = $DetectArea

var box_count = 0

func _ready():
	_update_label()
	if Engine.is_editor_hint():
		return
	add_to_group("button")
	anim.play("IDLE")
	detect_area.body_entered.connect(_on_body_entered)
	detect_area.body_exited.connect(_on_body_exited)

func _update_label() -> void:
	if not is_inside_tree():
		return
	if has_node("Label"):
		$Label.text = pair_name

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("box") or body.is_in_group("Togi"):
		box_count += 1
		if box_count == 1 and anim.animation != "CLICKIDLE":
			Click.play()
			anim.play("CLICK")
			await anim.animation_finished
			if box_count > 0:
				anim.play("CLICKIDLE")
				door_open.emit()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("box") or body.is_in_group("Togi"):
		box_count -= 1
		if box_count == 0 and anim.animation != "IDLE":
			anim.play("BUTTONUP")
			await anim.animation_finished
			if box_count == 0:
				anim.play("IDLE")
				door_close.emit()
