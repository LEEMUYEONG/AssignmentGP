extends Node

const SAVE_PATH = "user://save.json"

func save():
	var data = {}
	
	# 플레이어 위치
	var player = get_tree().get_first_node_in_group("player")
	data["player_position"] = {
		"x": player.global_position.x,
		"y": player.global_position.y
	}
	
	# 박스 위치/중력
	data["boxes"] = []
	for box in get_tree().get_nodes_in_group("box"):
		data["boxes"].append({
			"name": box.name,
			"x": box.global_position.x,
			"y": box.global_position.y,
			"gravity_x": box.gravity_direction.x,
			"gravity_y": box.gravity_direction.y
		})
	
	# 문 열림 상태
	data["doors"] = []
	for door in get_tree().get_nodes_in_group("door"):
		data["doors"].append({
			"name": door.name,
			"is_open": door.is_open
		})
	
	# JSON 저장
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	print("저장 완료!")

func load():
	if not FileAccess.file_exists(SAVE_PATH):
		print("저장 파일 없음")
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	
	# 플레이어 위치
	var player = get_tree().get_first_node_in_group("player")
	player.global_position = Vector2(data["player_position"]["x"], data["player_position"]["y"])
	
	# 박스
	for box_data in data["boxes"]:
		for box in get_tree().get_nodes_in_group("box"):
			if box.name == box_data["name"]:
				box.global_position = Vector2(box_data["x"], box_data["y"])
				box.gravity_direction = Vector2(box_data["gravity_x"], box_data["gravity_y"])
	
	# 문
	for door_data in data["doors"]:
		for door in get_tree().get_nodes_in_group("door"):
			if door.name == door_data["name"]:
				if door_data["is_open"]:
					door._on_door_open()
				else:
					door._on_door_close()
	
	print("불러오기 완료!")

func new_game():
	FileAccess.open(SAVE_PATH, FileAccess.WRITE).close()  # 파일 초기화
	get_tree().reload_current_scene()
