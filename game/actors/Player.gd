extends Character
class_name Player

@onready var animation_player: AnimationPlayer
@onready var animated_sprite: AnimatedSprite2D 
var attack_rate_timer: Timer
var death_timer: Timer
const DECELERATION: float = 50.0 

var character_datas = []
var current_character: Resource
var looking_left: bool
var input_enabled: bool = true

func _ready():
	animation_player = $AnimationPlayer
	animated_sprite = $AnimatedSprite2D
	
	# Add a timer to control attack rate
	attack_rate_timer = Timer.new()
	attack_rate_timer.one_shot = true
	add_child(attack_rate_timer)
	
	# Add a timer to control death 
	death_timer = Timer.new()
	death_timer.one_shot = true
	add_child(death_timer)
	
	# Load character resources
	character_datas.append(preload("res://resources/Rogue.tres"))
	character_datas.append(preload("res://resources/Mage.tres"))
	current_character = character_datas[1]
	
	attack_rate_timer.timeout.connect(_on_attack_rate_timeout)
	death_timer.timeout.connect(_on_death_timeout)

func _physics_process(_delta: float) -> void:
	#looking_left = get_global_mouse_position().x < global_position.x
	#$AnimatedSprite2D.flip_h = looking_left
	handle_input(get_input())  # Process the input and act accordingly
	#state_machine()  # Update the animation based on the current state
	
# Gather input data from the player
func get_input() -> Dictionary:
	var input_data = {
		"direction": Vector2.ZERO,
		"attack": false,
		"selected_character": null
	}

	if not input_enabled:
		return input_data
	
	# Get movement input
	input_data["direction"] = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()
	
	# Get attack input (e.g., spacebar)
	input_data["attack"] = Input.is_action_just_pressed("left_mouse_click")
	
	# Check for number key presses (1-9)
	for i in range(1, 10):  # Loop from 1 to 9
		if Input.is_action_just_pressed(str(i)):  # Check if the key for 'i' is pressed
			input_data["selected_character"] = i  # Store the pressed number
			print(input_data["selected_character"])
			
	return input_data

# Process the gathered input and handle character movement and actions
func handle_input(input_data: Dictionary) -> void:
	if input_data["attack"]:
		attack()			
	elif input_data["direction"] != Vector2.ZERO:
		handle_movement(get_input()["direction"]) 
		
	if input_data["selected_character"]:
		switch_character(input_data["selected_character"])

func switch_character(character_num: int):
	print("Switch Character")
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
		return #Avoid attacking if still on cooldown
		
	# Disable input and start the timer for attack cooldown
	input_enabled = false
	attack_rate_timer.wait_time = current_character.attack_rate
	attack_rate_timer.start()
	
	# Play attacking animation	
	animation_player.play(current_character.character_name + "_Attack")
	
func launch_projectile(scene: PackedScene, projectile_speed: int):
	
	var projectile_inst = scene.instantiate()
	
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
		
	projectile_inst.position = $ShootingPoint.get_global_position() + Vector2(30 * direction, -10 * direction) 
		
	# Apply velocity to the projectile in the facing direction
	projectile_inst.apply_central_impulse(Vector2(projectile_speed * direction, 0))
	get_tree().get_root().add_child(projectile_inst)
	
	# Play projectile animation
	var projectile_animation_player = projectile_inst.get_node("AnimationPlayer")
	projectile_animation_player.queue("Shoot_Fireball")

func _on_death_timeout():
	input_enabled = false
	
	#TO DO write a function that can choose the next closest alive character after death
	switch_character(1)
	queue_free()
		
func _on_attack_rate_timeout():
	# Get attack data and execute attack logic
	var attack_data = current_character.get_attack_data()
	var attack_type: String = attack_data["attack_type"]
	if attack_type == "projectile":
		launch_projectile(attack_data["projectile_scene"], attack_data["projectile_speed"])
	elif attack_type == "melee":
		print("Melee Attack")
		pass
		
	input_enabled = true
	animation_player.play(current_character.character_name + "_Idle")			

# Handle movement and animation based on direction input
func handle_movement(direction: Vector2) -> void:
	print("Moving")
	velocity = direction * current_character.speed
	
	# Flip the player to the direction they are moving in
	$AnimatedSprite2D.flip_h = direction.x < 0

	if not animation_player.is_playing():
		animation_player.play(current_character.character_name + "_Walk")
		animation_player.queue(current_character.character_name + "_Idle")
		
	move_and_slide()
	
func take_damage(damage: int):
	current_character.current_health -= damage
	print(current_character.current_health)
	if current_character.current_health <= 0:
		animation_player.play(current_character.character_name + "_Death")
		queue_free()
		# Start a death timer
		death_timer.wait_time = 1.5
		death_timer.start()
