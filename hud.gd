extends CanvasLayer
@onready var label = $ALabel
@onready var player = $"../Player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.hud_message.connect(_on_hud_message)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_hud_message(msg):
	show_message(msg)

func show_message(msg):
	label.text = msg
	label.visible = true
	label.modulate.a = 1.0

	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_property(label, "modulate:a", 0.0, 1.0)

	await tween.finished
	label.visible = false
