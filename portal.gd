extends Area2D

@export var next_scene: String = "res://scenes/ending.tscn"
@export var requires_artifact: bool = true  # 토기 필요 여부
var triggered := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player") or triggered:
		return
	
	if requires_artifact and not body.has_artifact:
		# 토기 없이 통과 시 → 그냥 무시 또는 힌트 표시
		print("토기가 필요합니다!")
		return
	
	triggered = true
	fade_and_change()

func fade_and_change() -> void:
	var overlay = get_tree().get_first_node_in_group("fade_overlay")
	var tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, 0.5)
	tween.tween_callback(
		func(): get_tree().change_scene_to_file(next_scene)
	)
