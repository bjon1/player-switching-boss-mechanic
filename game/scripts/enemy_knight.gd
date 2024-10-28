extends Enemy
class_name EnemyKnight

func _ready():
	super._ready()
	for character in character_datas:
		if character.character_name == "Knight":
			current_character = character # Select he Knight

func _on_detection_area_body_entered(body) -> void:
	if body.is_in_group("player"):
		print("Detection Area Entered")
		adversary = body
		collision_data["in_detection_area"] = true
	
func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == adversary:
		print("Detection Area Exited")
		adversary = null
		collision_data["in_detection_area"] = false
	animation_player.play(current_character.character_name + "_Idle")	
		
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body == adversary:
		collision_data["in_attack_area"] = true

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body == adversary:
		collision_data["in_attack_area"] = false
	animation_player.play(current_character.character_name + "_Idle")	
	
		
		
