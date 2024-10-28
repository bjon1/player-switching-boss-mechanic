extends CharacterBody2D
class_name Character

@onready var animation_player: AnimationPlayer
@onready var animated_sprite: AnimatedSprite2D 
var attack_rate_timer: Timer
var death_timer: Timer
var adversary: CharacterBody2D
var adversary_in_attack_range: bool
var current_character: Resource
var character_datas = [ preload("res://resources/Rogue.tres"), preload("res://resources/Mage.tres") ]

func _ready():
	animation_player = get_node("AnimationPlayer")
	animated_sprite = get_node("AnimationSprite2D")
	
	# Add a timer to control attack rate
	attack_rate_timer = Timer.new()
	attack_rate_timer.one_shot = true
	add_child(attack_rate_timer)
	
	# Add a timer to control death 
	death_timer = Timer.new()
	death_timer.one_shot = true
	add_child(death_timer)
	
	
# Implemented in the children 
func _on_attack_rate_timeout():
	# Get attack data and execute attack logic
	var attack_data = current_character.get_attack_data()
	if attack_data["attack_type"] == "projectile":
		launch_projectile(attack_data["projectile_scene"], attack_data["projectile_speed"])
	if adversary_in_attack_range: # If the player is still in attacking range
		adversary.take_damage(current_character.attack_damage)
	animation_player.play(current_character.character_name + "_Idle")		

func launch_projectile(scene: PackedScene, projectile_speed: int):
	# Instantiate Projectile
	var projectile_inst = scene.instantiate()
	# Turn off Gravity
	if projectile_inst is RigidBody2D:
		projectile_inst.gravity_scale = 0
	# Update the direction
	var direction: int = 1
	if velocity.x > 0:
		direction = 1
		projectile_inst.rotation_degrees = 0 # Face Right
	elif velocity.x < 0:
		direction = -1
		projectile_inst.rotation_degrees = 180 # Face Left
 	# Set the position of the projectile
	projectile_inst.position = $ShootingPoint.get_global_position() + Vector2(30 * direction, -10 * direction) 
	# Apply velocity to the projectile in the facing direction
	projectile_inst.apply_central_impulse(Vector2(projectile_speed * direction, 0))
	get_tree().get_root().add_child(projectile_inst)
	# Play projectile animation
	var projectile_animation_player = projectile_inst.get_node("AnimationPlayer")
	projectile_animation_player.queue("Shoot_Fireball")
	
func _on_death_timeout():
	while current_character in character_datas:
		character_datas.erase(current_character)
	
func switch_character(character_num: int):
	print("Switch Character", str(character_num))
	# If the character has not been implemented yet
	if character_num > len(character_datas):
		return
	# If the character has already been chosen
	if character_datas[character_num-1] == current_character:
		return
	current_character = character_datas[character_num-1]
	print("Switched to " + current_character.character_name)
	animation_player.play(current_character.character_name + "_Idle")
	print(character_datas[character_num-1])

func attack():
	if not attack_rate_timer.is_stopped():
		return # Avoid attacking if still on cooldown
	# Start the attack rate timer
	attack_rate_timer.wait_time = current_character.attack_rate
	attack_rate_timer.start()
	# Play attacking animation	
	animation_player.play(current_character.character_name + "_Attack")

func take_damage(damage: int):
	if not death_timer.is_stopped():
		print("PLAYER Dying, no more damage taken")
		return
	current_character.current_health -= damage
	print(current_character.current_health)
	if current_character.current_health <= 0:
		animation_player.play(current_character.character_name + "_Death")
		# Start a death timer
		death_timer.wait_time = 1.5
		death_timer.start()

'''
	
func take_damage():
	
func die():
'''
	
