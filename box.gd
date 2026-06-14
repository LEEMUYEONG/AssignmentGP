extends RigidBody2D

@onready var PICK_UP = $AudioStreamPlayer2D
@export var start_gravity: Vector2 = Vector2.DOWN
@onready var collision = $CollisionShape2D
@onready var detect_area = $DetectArea
@onready var q_label = $"../HUD/QLabel"

var gravity_direction = Vector2.DOWN
var gravity_strength = 980.0

func _ready():
	add_to_group("box")
	gravity_direction = start_gravity  # ✅
	gravity_scale = 0
	contact_monitor = true
	max_contacts_reported = 4
	detect_area.body_entered.connect(_on_body_entered)
	detect_area.body_exited.connect(_on_body_exited)

func _physics_process(delta):
	if not freeze:
		apply_central_force(gravity_direction * gravity_strength)
	# ✅ 이 박스가 nearby_box일 때만 위치 갱신
	var player = get_parent().get_node_or_null("Player")
	if player and player.nearby_box == self:
		var screen_pos = get_global_transform_with_canvas().origin
		q_label.position = screen_pos + Vector2(-q_label.size.x / 2, -80)

func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		body.nearby_box = self
		q_label.visible = true

func _on_body_exited(body: Node) -> void:
	if body.name == "Player":
		body.nearby_box = null
		q_label.visible = false

func pick_up():
	PICK_UP.play()
	freeze = true
	collision.disabled = true
	q_label.visible = false
	hide()

func put_down(pos: Vector2):
	PICK_UP.play()
	global_position = pos
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	collision.disabled = false
	freeze = false
	show()

func get_collision_shape():
	return collision.shape
