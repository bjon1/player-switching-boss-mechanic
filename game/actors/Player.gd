extends Character
class_name Player

const DECELERATION: float = 50.0 
const FRICTION = 600
const ACCELERATION = 600
const MAX_SPEED = 225
const JUMP_POWER = 500
const GRAVITY = 1000  # Adjusted to a higher value for natural fall speed
const MAX_FALL_SPEED = 800  # Cap the maximum fall speed to prevent endless acceleration

var player_direction = 0
var is_on_ground: bool = false  # Track if the player is on the ground
var last_jump_position = Vector2.ZERO

func _ready():
	super._ready()
	collision_data["in_detection_area"] = true 
	character_datas = [character_datas[0], character_datas[1]]
	current_character = character_datas[0]
	attack_rate_timer.timeout.connect(_on_player_attack_rate_timeout) 
	death_timer.timeout.connect(_on_player_death_timeout)
	ultimate_timer.timeout.connect(_on_player_ultimate_timeout)
	SignalBus.enemy_died.connect(_on_enemy_died)
	
	Debug.log("PLAYER " + str(current_character.current_health))
	animation_player.play(current_character.character_name + "_Idle")
	
	call_deferred('emit_health_signal')

func _physics_process(delta: float) -> void:
	
	#update_animation_parameters()
		
	handle_movement_logic(delta)
	handle_jump_and_gravity(delta)
	
	if Input.is_action_just_pressed("left_mouse_click"):
		player_attack()
	if Input.is_action_just_pressed("ultimate_key"):
		player_ultimate_ability()

	# Check for number key presses (1 to # of Characters Available)
	for i in range(1, len(character_datas) + 1): 
		if Input.is_action_just_pressed(str(i)):
			switch_character(i)
			


func handle_jump_and_gravity(delta: float) -> void:

	# Check if the player is on the ground
	is_on_ground = is_on_floor()

	# Jump logic
	if Input.is_action_just_pressed("spacebar") and is_on_ground:
		save_jump_position()
		velocity.y = -JUMP_POWER  # Apply an upward force

	# Gravity logic
	if not is_on_ground:
		velocity.y += GRAVITY * delta
		velocity.y = min(velocity.y, MAX_FALL_SPEED)  # Cap fall speed to MAX_FALL_SPEED

	# Movement with gravity applied
	move_and_slide()
	
func save_jump_position():
	last_jump_position = global_position
	
func teleport_to_last_jump_position():
	global_position = last_jump_position

func handle_movement_logic(delta: float) -> void:
	var movement_data = get_movement_input()
	handle_movement_animation(movement_data)
	var speed = current_character.speed
	
	if movement_data == Vector2.ZERO:
		if velocity.length() > (FRICTION * delta):
			velocity -= velocity.normalized() * (FRICTION * delta)
		else:
			velocity.x = 0
	else:
		velocity.x += movement_data.x * ACCELERATION * delta
		velocity.x = clamp(velocity.x, -speed, speed)

func handle_movement_animation(direction_vector: Vector2) -> void:
	if direction_vector.x > 0:
		player_direction = 1
		$AttackArea.scale.x = abs(scale.x)
		$CollisionShape2D.scale.x = abs(scale.x)
		$AnimatedSprite2D.flip_h = false
	elif direction_vector.x < 0:
		player_direction = -1
		$AttackArea.scale.x = -(scale.x)
		$CollisionShape2D.scale.x = -(scale.x)
		$AnimatedSprite2D.flip_h = true

	if not animation_player.is_playing():
		if velocity.x != 0 and is_on_ground:
			animation_player.play(current_character.character_name + "_Walk")
		elif is_on_ground:
			animation_player.play(current_character.character_name + "_Idle")
		else:
			animation_player.play(current_character.character_name + "_Jump")


	# Check for number key presses (1 to # of Characters Available)
	for i in range(1, len(character_datas) + 1): 
		if Input.is_action_just_pressed(str(i)):  # Check if the key for 'i' is pressed
			switch_character(i)

	
func add_new_character(character_data: Resource):
	character_datas.append(character_data)
	print("New Character Unlocked!")	

# Gather input data from the player
func get_movement_input() -> Vector2:
	
	if not movement_enabled:
		return Vector2.ZERO
		
	var movement_input = Vector2.ZERO
	movement_input.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	movement_input.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	movement_input = movement_input.normalized()
	return movement_input	
	
func switch_character(character_num: int):
	print("Switch Character ", str(character_num))
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
	emit_health_signal()

func player_attack():
	if not movement_enabled:
		return
	else: 
		attack()
	
func player_ultimate_ability():
	ultimate_ability()
	print("ultimate ability started")
	
func launch_projectile(scene: PackedScene, projectile_speed: int):
	# Instantiate Projectile
	var projectile_inst = scene.instantiate()
	# Turn off Gravity
	if projectile_inst is RigidBody2D:
		projectile_inst.gravity_scale = 0
	# Update the direction
	if player_direction == 1:
		projectile_inst.rotation_degrees = 0 # Face Right
	elif player_direction == -1:
		projectile_inst.rotation_degrees = 180 # Face Left
 	# Set the position of the projectile
	projectile_inst.position = $ShootingPoint.get_global_position() + Vector2(56 * player_direction, -10 * player_direction) 
	# Apply velocity to the projectile in the facing direction
	projectile_inst.apply_central_impulse(Vector2(projectile_speed * player_direction, 0))
	get_tree().get_root().add_child(projectile_inst)
	# Play projectile animation
	var projectile_animation_player = projectile_inst.get_node("AnimationPlayer")
	projectile_animation_player.queue("Shoot_Fireball")

func collided_with_death_border():
	die()
	teleport_to_last_jump_position()
	
func _on_player_ultimate_timeout():
	_on_ultimate_timeout()
	change_player_group($".", "hidden", "player")
	print("ultimate ended")
	
func _on_player_attack_rate_timeout():
	# Get attack data and execute attack logic
	var attack_data = current_character.get_attack_data()
	if attack_data["attack_type"] == "projectile":
		launch_projectile(attack_data["projectile_scene"], attack_data["projectile_speed"])

	_on_attack_rate_timeout()

func _on_player_death_timeout():
	_on_death_timeout()
	if len(character_datas) > 0:
		switch_character(0)
	else:
		player_lose_screen()
	
func player_lose_screen():
	Debug.log("Game Over!! Emitting lose game screen")
	SignalBus.lose_game.emit()
	queue_free()
	

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		adversary = body
		collision_data["in_attack_area"] = true
		print("PLAYER's Attack Area Entered")

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body == adversary:
		body = null
		collision_data["in_attack_area"] = false
		print("PLAYER's Attack Area Exited")
	
func _on_enemy_died(character_data: Resource):
	character_data.current_health = character_data.max_health
	add_new_character(character_data)
	
