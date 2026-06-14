extends CharacterBody2D

signal hud_message(msg)

@export var SPEED: float = 300.0
const JUMP_VELOCITY: float = -340.0

var gravity_direction = Vector2.DOWN
var gravity_strength = 980.0
var holding_box = null
var nearby_box = null

@onready var cb = get_tree().get_first_node_in_group("cb")
@onready var footstep_sound = $AudioStreamPlayer2D
@onready var anim = $AnimatedSprite2D
@onready var floor_ray = $FloorRay
@onready var ALabel = $"../HUD/ALabel"

func _ready():
	add_to_group("player")
	anim.frame_changed.connect(_on_frame_changed)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("HOLD"):
		if holding_box:
			var forward = Vector2(gravity_direction.y, -gravity_direction.x)
			if anim.flip_h:
				forward = -forward
			var drop_pos = global_position + (-gravity_direction * 0) + (forward * 12)
			var space_state = get_world_2d().direct_space_state
			var query = PhysicsShapeQueryParameters2D.new()
			query.shape = holding_box.get_collision_shape()
			query.transform = Transform2D(0, drop_pos)
			query.collide_with_bodies = true
			query.exclude = [self]
			var result = space_state.intersect_shape(query)
			if result.is_empty():
				holding_box.put_down(drop_pos)
				holding_box = null
			else:
				print("놓을 공간이 없습니다.")
				hud_message.emit("놓을 공간이 없습니다.")
		elif nearby_box:
			holding_box = nearby_box
			holding_box.pick_up()

func _is_holding_togi() -> bool:
	return holding_box != null and holding_box.is_in_group("togi")

func _is_holding_box() -> bool:
	return holding_box != null and holding_box.is_in_group("box")

func _physics_process(delta: float) -> void:
	if holding_box:
		var forward = Vector2(gravity_direction.y, -gravity_direction.x)
		if anim.flip_h:
			forward = -forward
		holding_box.global_position = global_position + (-gravity_direction * 10) + (forward * 12)

	var on_floor = floor_ray.is_colliding()

	if not on_floor:
		velocity += gravity_direction * gravity_strength * delta

	if Input.is_action_just_pressed("ui_accept") and on_floor:
		if holding_box == null:
			velocity += -gravity_direction * abs(JUMP_VELOCITY)
		else:
			velocity += -gravity_direction * 300.0

	var direction := Input.get_axis("ui_left", "ui_right")
	
	up_direction = -gravity_direction

	if !cb.Ing:
		var tangent = Vector2(gravity_direction.y, -gravity_direction.x)
		if direction:
			var gravity_velocity = velocity.project(gravity_direction)
			velocity = gravity_velocity + tangent * direction * SPEED
			anim.flip_h = direction < 0
		else:
			var gravity_velocity = velocity.project(gravity_direction)
			var side_speed = velocity.dot(tangent)
			side_speed = move_toward(side_speed, 0, SPEED)
			velocity = gravity_velocity + tangent * side_speed

		if not on_floor:
			if _is_holding_togi():
				anim.play("TOGIDLE")   # 토기 들고 공중
			elif _is_holding_box():
				anim.play("BOXIDLE")   # 박스 들고 공중
			else:
				anim.play("JUMP")
		elif _is_holding_togi():
			if direction:
				anim.play("TOGIWALK")
			else:
				anim.pause()
		elif _is_holding_box():
			if direction:
				anim.play("BOXWALK")
			else:
				anim.pause()
		elif direction:
			anim.play("WALK")
		else:
			anim.play("IDLE")

		move_and_slide()

	else:
		# cb 회전 중 → 이전 애니메이션 유지 (아무것도 바꾸지 않음)
		move_and_slide()

func show_message():
	visible = true
	modulate.a = 1.0
	var tween = create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.finished.connect(func():
		visible = false
	)

func _on_frame_changed():
	if anim.animation in ["WALK", "BOXWALK", "TOGIWALK"] and anim.frame in [0, 3]:
		footstep_sound.play()
