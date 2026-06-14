extends Area2D

@export var can_turn_left: bool = true
@export var can_turn_right: bool = true
@export var can_turn_up: bool = true
@export var can_turn_down: bool = true

var player_inside = false
var Ing = false
var Fly = true
var selecting_direction = false
var current_cam_rotation: int = 0

@onready var CH = $AudioStreamPlayer2D
@onready var player = $"../Player"
@onready var player_cam = $"../Player/Camera2D"
@onready var animC = $"../CB/AnimatedSprite2D"
@onready var anim = $"../Player/AnimatedSprite2D"
@onready var e_label = $"../HUD/ELabel"
@onready var left_label = $"../HUD/LeftLabel"
@onready var right_label = $"../HUD/RightLabel"
@onready var up_label = $"../HUD/UpLabel"
@onready var down_label = $"../HUD/DownLabel"

@onready var col0   = $"../Player/Col0"
@onready var col90  = $"../Player/Col90"
@onready var col180 = $"../Player/Col180"
@onready var col270 = $"../Player/Col270"

func _ready() -> void:
	add_to_group("cb")
	anim.play("IDLE")
	hide_all_labels()
	player_cam.enabled = true
	current_cam_rotation = int(player_cam.rotation_degrees) % 360

func _process(_delta: float) -> void:
	if player_inside and (e_label.visible or selecting_direction):
		update_ui_position()
	if player_inside and !Ing:
		if Input.is_action_just_pressed("INTERACTION") and !selecting_direction:
			if not _is_player_standing():
				return
			selecting_direction = true
			e_label.visible = false
			if can_turn_left: left_label.visible = true
			if can_turn_right: right_label.visible = true
			if can_turn_up: up_label.visible = true
			if can_turn_down: down_label.visible = true
		if selecting_direction:
			if can_turn_left and Input.is_action_just_pressed("TURNLEFT"):
				hide_all_labels()
				rotate_camera_to(270)
			if can_turn_right and Input.is_action_just_pressed("TURNRIGHT"):
				hide_all_labels()
				rotate_camera_to(90)
			if can_turn_up and Input.is_action_just_pressed("TURNUP"):
				hide_all_labels()
				rotate_camera_to(180)
			if can_turn_down and Input.is_action_just_pressed("TURNDOWN"):
				hide_all_labels()
				rotate_camera_to(0)

func update_ui_position() -> void:
	var screen_pos = get_global_transform_with_canvas().origin
	e_label.position = screen_pos + Vector2(35 - e_label.size.x / 2, -110)

	# [위, 밑, 좌, 우] 순서
	var order = {
		0:   [up_label, down_label, left_label, right_label],
		90:  [left_label, right_label, down_label, up_label],
		180: [down_label, up_label, right_label, left_label],
		270: [right_label, left_label, up_label, down_label],
	}
	var offsets = [
		Vector2(0, -120),   # 위
		Vector2(0, 60),     # 밑
		Vector2(90, -30),   # 좌
		Vector2(-90, -30),  # 우
	]

	var labels = order[current_cam_rotation]
	for i in 4:
		labels[i].position = screen_pos + offsets[i] + Vector2(-labels[i].size.x / 2, 0)
		
func rotate_camera(angle: int) -> void:
	var target = current_cam_rotation + angle
	await _do_rotate(target)

func rotate_camera_to(target_degrees: int) -> void:
	await _do_rotate(target_degrees)

func _do_rotate(target_degrees: int) -> void:
	Ing = true
	selecting_direction = false
	CH.play()

	var angle = target_degrees - current_cam_rotation
	
	# 최단 경로로 회전 (-180 ~ 180 범위로 정규화)
	if angle > 180:
		angle -= 360
	elif angle < -180:
		angle += 360
	
	current_cam_rotation = target_degrees

	var step = 1 if angle > 0 else -1
	for i in range(abs(angle)):
		player_cam.rotation_degrees += step
		update_ui_position()
		await get_tree().create_timer(0.008).timeout

	player.gravity_direction = player.gravity_direction.rotated(deg_to_rad(angle)).round()
	player.floor_ray.target_position = player.floor_ray.target_position.rotated(deg_to_rad(angle))

	anim.rotation_degrees += angle

	if player.holding_box:
		player.holding_box.gravity_direction = player.holding_box.gravity_direction.rotated(deg_to_rad(angle)).round()

	_update_colliders()
	CH.stop()
	Ing = false

func _update_colliders() -> void:
	var grav = player.gravity_direction
	col0.disabled   = not (grav == Vector2.DOWN)
	col90.disabled  = not (grav == Vector2.RIGHT)
	col180.disabled = not (grav == Vector2.UP)
	col270.disabled = not (grav == Vector2.LEFT)

func hide_all_labels():
	e_label.visible = false
	left_label.visible = false
	right_label.visible = false
	up_label.visible = false
	down_label.visible = false

func fade_label(label: Label):
	label.visible = true
	label.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_property(label, "modulate:a", 0.0, 1.0)
	await tween.finished
	label.visible = false
	label.modulate.a = 1.0

func _is_player_standing() -> bool:
	var direction = Input.get_axis("ui_left", "ui_right")
	return direction == 0

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var raw = int(round(player_cam.rotation_degrees)) % 360
		if raw < 0:
			raw += 360
		current_cam_rotation = raw
		player_inside = true
		hide_all_labels()
		update_ui_position()
		e_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_inside = false
		selecting_direction = false
		hide_all_labels()
