extends Character
class_name Player

const DECELERATION: float = 50.0 
var looking_left: bool

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

func _physics_process(_delta: float) -> void:
	#looking_left = get_global_mouse_position().x < global_position.x
	#$AnimatedSprite2D.flip_h = looking_left
	handle_input(get_input())  # Process the input and act accordingly
	#state_machine()  # Update the animation based on the current state
	
func add_new_character(character_data: Resource):
	character_datas.append(character_data)
	print("New Character Unlocked!")	

# Gather input data from the player
func get_input() -> Dictionary:
	var input_data = {
		"direction": Vector2.ZERO,
		"attack": false,
		"ultimate": null,
		"selected_character": null
	}

	if not movement_enabled:
		return input_data
	
	# Get movement input
	input_data["direction"] = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()
	
	# Get attack input (e.g., spacebar)
	input_data["attack"] = Input.is_action_just_pressed("left_mouse_click")
	
	# Get ultimate input
	input_data["ultimate"] = Input.is_action_just_pressed("ultimate_key")
	
	# Check for number key presses (1 to # of Characters Available)
	for i in range(1, len(character_datas) + 1): 
		if Input.is_action_just_pressed(str(i)):  # Check if the key for 'i' is pressed
			input_data["selected_character"] = i  # Store the pressed number
			print(input_data["selected_character"])			
			
	return input_data

# Process the gathered input and handle character movement and actions
func handle_input(input_data: Dictionary) -> void:
	if input_data["ultimate"]:
		player_ultimate_ability()
	elif input_data["attack"]:
		player_attack()			
	elif input_data["direction"] != Vector2.ZERO:
		handle_movement(get_input()["direction"]) 
	if input_data["selected_character"]:
		switch_character(input_data["selected_character"])
		
func player_attack():
	attack()
	
func player_ultimate_ability():
	ultimate_ability()
	SignalBus.ultimate_started.emit()
	print("ultimate ability started")
	
func _on_player_ultimate_timeout():
	_on_ultimate_timeout()
	SignalBus.ultimate_ended.emit()
	print("ultimate ended")
	
func _on_player_attack_rate_timeout():
	var attack_type = _on_attack_rate_timeout()

func _on_player_death_timeout():
	_on_death_timeout()
	if len(character_datas) > 0:
		switch_character(0)
	else:
		player_lose_screen()
	
func player_lose_screen():
	print("Game Over!!")
	queue_free()

# Handle movement and animation based on direction input
func handle_movement(direction: Vector2) -> void:
	velocity = direction * current_character.speed
	
	# Flip the player to the direction they are moving in
	if direction.x > 0:
		$AnimatedSprite2D.flip_h = false
		$AttackArea.scale = abs($AttackArea.scale)
	else:
		$AnimatedSprite2D.flip_h = true
		$AttackArea.scale = -$AttackArea.scale
	
	if not animation_player.is_playing():
		animation_player.play(current_character.character_name + "_Walk")
		animation_player.queue(current_character.character_name + "_Idle")
		
	move_and_slide()		

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
	
