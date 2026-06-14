extends Control

@onready var clear_image = $ClearImage
@onready var retry_button = $RetryButton
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	clear_image.modulate.a = 0.0
	retry_button.modulate.a = 0.0

	var tween = create_tween()
	tween.tween_property(clear_image, "modulate:a", 1.0, 0.6)
	tween.tween_interval(0.2)
	tween.tween_property(retry_button, "modulate:a", 1.0, 0.4)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
