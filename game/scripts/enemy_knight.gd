extends Enemy
class_name EnemyKnight

const TELEPORT_RADIUS: float = 150.0  # Maximum radius within which the enemy can teleport closer to the player
const TELEPORT_CHANCE: float = 0.005

func _ready():
	super._ready()
	for character in character_datas:
		if character.character_name == "Knight":
			current_character = character # Select he Knight

func _physics_process(delta):
	status_checker(delta)	
	handle_teleport()
	
func handle_teleport():
	if adversary and should_teleport():  # Check if the enemy should teleport
		teleport_closer_to_player()
	
func teleport_closer_to_player():
	if not adversary or not movement_enabled:
		return

	# Get a random offset within the TELEPORT_RADIUS
	var random_angle = randf() * PI * 2  # Random angle in radians
	var random_distance = randf() * TELEPORT_RADIUS  # Random distance within radius
	var offset = Vector2(cos(random_angle), sin(random_angle)) * random_distance
	
	# 50% chance to teleport behind or in front of player
	if randf() < 0.5:
		offset = -offset
	
	# Calculate the new position relative to the player
	var new_position = adversary.global_position + offset
	
	# Update the enemy's position
	position = new_position
	print("Enemy teleported to position:", position)

func should_teleport() -> bool:
	# 30% chance to teleport
	if randf() < TELEPORT_CHANCE:
		# Additional condition: only teleport if the enemy is far from the player
		return position.distance_to(adversary.global_position) > 300
	return false

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
	
		
		
