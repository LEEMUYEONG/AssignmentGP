@tool
extends AnimatableBody2D

@export var move_distance: float = 200.0:
	set(value):
		move_distance = value
		queue_redraw()  # 값 바뀌면 즉시 갱신

@export var move_speed: float = 2.0
@export var move_direction: Vector2 = Vector2(1, 0):
	set(value):
		move_direction = value
		queue_redraw()

var start_position: Vector2
var time: float = 0.0

func _ready() -> void:
	start_position = position

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	time += delta * move_speed
	var offset = sin(time) * move_distance
	position = start_position + move_direction * offset

func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	draw_set_transform(Vector2.ZERO, -global_rotation, Vector2.ONE)
	var dir = move_direction.normalized()
	var start = dir * -move_distance
	var end = dir * move_distance
	draw_line(start, end, Color.CYAN, 2.0)
	draw_circle(start, 6.0, Color.CYAN)
	draw_circle(end, 6.0, Color.CYAN)
	draw_circle(Vector2.ZERO, 4.0, Color.YELLOW)
