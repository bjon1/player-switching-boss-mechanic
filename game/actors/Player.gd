extends Character
class_name Player

const DECELERATION: float = 50.0 
const FRICTION = 600
const ACCELERATION = 1500
const MAX_SPEED = 225
var player_direction = 0

func _ready():
	# Call the parent _ready() to ensure everything is set up
	super._ready()
	# Player has no need for a detection area
	collision_data["in_detection_area"] = true 
	character_datas = [character_datas[0], character_datas[1]]
	current_character = character_datas[0]
	attack_rate_timer.timeout.connect(_on_player_attack_rate_timeout) 
	death_timer.timeout.connect(_on_player_death_timeout)
	ultimate_timer.timeout.connect(_on_player_ultimate_timeout)
	SignalBus.enemy_died.connect(_on_enemy_died)
	
	animation_player.play(current_character.character_name + "_Idle") # Set Opening Sprite

func _physics_process(delta: float) -> void:
	handle_movement_logic(delta)	
	if Input.is_action_just_pressed("left_mouse_click"):
		player_attack()		
	if Input.is_action_just_pressed("ultimate_key"):
		player_ultimate_ability()
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
	
func handle_movement_logic(delta):
	var movement_data = get_movement_input()
	handle_movement_animation(movement_data)
	print("Velocity", velocity)
	
	if movement_data == Vector2.ZERO:
		if velocity.length() > (FRICTION * delta):
			velocity -= velocity.normalized() * (FRICTION * delta)
		else:
			velocity = Vector2.ZERO
	else:
		velocity += (movement_data * ACCELERATION * delta)
		velocity = velocity.limit_length(current_character.speed)
		
	move_and_slide()
	
func handle_movement_animation(direction_vector: Vector2) -> void:
	if direction_vector.x > 0:
		player_direction = 1
		$AttackArea.scale.x = abs(scale.x)
		$CollisionShape2D.scale.x = abs(scale.x)
		$AnimatedSprite2D.flip_h = false
		$ShootingPoint.scale.x = abs(scale.x)
	elif direction_vector.x < 0:
		player_direction = -1
		$AttackArea.scale.x = -(scale.x)
		$CollisionShape2D.scale.x = -(scale.x)
		$AnimatedSprite2D.flip_h = true
		$ShootingPoint.scale.x = -(scale.x)
	
	if not animation_player.is_playing():
		if velocity != Vector2.ZERO:
			animation_player.play(current_character.character_name + "_Walk")
		else:
			animation_player.play(current_character.character_name + "_Idle")
		
func player_attack():
	attack()
	
func player_ultimate_ability():
	ultimate_ability()
	SignalBus.ultimate_started.emit()
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
	projectile_inst.position = $ShootingPoint.get_global_position() + Vector2(30 * player_direction, -10 * player_direction) 
	# Apply velocity to the projectile in the facing direction
	projectile_inst.apply_central_impulse(Vector2(projectile_speed * player_direction, 0))
	get_tree().get_root().add_child(projectile_inst)
	# Play projectile animation
	var projectile_animation_player = projectile_inst.get_node("AnimationPlayer")
	projectile_animation_player.queue("Shoot_Fireball")
	
func _on_player_ultimate_timeout():
	_on_ultimate_timeout()
	SignalBus.ultimate_ended.emit()
	print("ultimate ended")
	
func _on_player_attack_rate_timeout():
	# Get attack data and execute attack logic
	var attack_data = current_character.get_attack_data()
	if attack_data["attack_type"] == "projectile":
		launch_projectile(attack_data["projectile_scene"], attack_data["projectile_speed"])
	if collision_data["in_attack_area"]: # If the player is still in attacking range
		adversary.take_damage(current_character.attack_damage)

	_on_attack_rate_timeout()

func _on_player_death_timeout():
	_on_death_timeout()
	if len(character_datas) > 0:
		switch_character(0)
	else:
		player_lose_screen()
	
func player_lose_screen():
	print("Game Over!!")
	queue_free()
	
func player_take_damage(damage: int):
	take_damage(damage)

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
	add_new_character(character_data)
	
