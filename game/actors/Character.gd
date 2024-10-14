extends CharacterBody2D
class_name Character


#@onready var animation_player: AnimationPlayer
@onready var animated_sprite: AnimatedSprite2D 
var input_enabled: bool = true
var character_datas = []
var current_character: CharacterData
const DECELERATION: float = 50.0 

func _ready():
	#animation_player = $AnimationPlayer
	animated_sprite = $AnimatedSprite2D
	character_datas.append(preload("res://resources/Rogue.tres"))
	character_datas.append(preload("res://resources/Mage.tres"))
	current_character = character_datas[0]

func _physics_process(_delta: float) -> void:
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
	input_data["attack"] = Input.is_action_just_pressed("spacebar")
	
	# Check for number key presses (1-9)
	for i in range(1, 10):  # Loop from 1 to 9
		if Input.is_action_just_pressed(str(i)):  # Check if the key for 'i' is pressed
			input_data["selected_character"] = i  # Store the pressed number
			print(input_data["selected_character"])
			
	
	return input_data

# Process the gathered input and handle character movement and actions
func handle_input(input_data: Dictionary) -> void:
	if input_data["attack"]:
		current_character.attack()		
	elif input_data["direction"] != Vector2.ZERO:
		handle_movement(get_input()["direction"]) 
	elif input_data["selected_character"]:
		switch_character(input_data["selected_character"])

func switch_character(character_num: int):
	if character_num > len(character_datas):
		return
	current_character = character_datas[character_num-1]
	print("Switched to " + current_character.character_name)
	print(character_datas[character_num-1])

# Handle movement and animation based on direction input
func handle_movement(direction: Vector2) -> void:
	print("Moving")
	if direction != Vector2.ZERO:
		velocity = direction * current_character.speed
		print("SPEED")
		print(current_character.speed)
		
		# Flip sprite based on movement direction
		if direction.x:
			animated_sprite.flip_h = direction.x < 0
		if not animated_sprite.is_playing():
			animated_sprite.play("Rogue_Walk")
	else:
		# Decelerate when not moving
		velocity.x = move_toward(velocity.x, 0, DECELERATION)
		velocity.y = move_toward(velocity.y, 0, DECELERATION)
	move_and_slide()
