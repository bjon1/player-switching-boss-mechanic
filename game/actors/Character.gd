extends CharacterBody2D
class_name Character

enum State {
	IDLE,
	WALK,
	ATTACK
}

var current_state = State.IDLE

const DECELERATION: float = 50.0 
@export var current_health: int = 100
@export var max_health: int = 100
@export var health_regen: float = 0.1
@export var health_regen_delay: float = 1.0
@export var speed: float = 150.0
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var input_enabled: bool = true

func _physics_process(_delta: float) -> void:
	handle_input(get_input())  # Process the input and act accordingly
	#state_machine()  # Update the animation based on the current state
	
# Gather input data from the player
func get_input() -> Dictionary:
	var input_data = {
		"direction": Vector2.ZERO,
		"attack": false
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
	
	return input_data

# Process the gathered input and handle character movement and actions
func handle_input(input_data: Dictionary) -> void:
	if input_data["attack"]:
		animation_player.stop()
		animation_player.queue("Attack")
		execute_attack()
	elif input_data["direction"] != Vector2.ZERO:
		animation_player.play("Walk")		
		handle_movement(get_input()["direction"]) 
	else:
		animation_player.queue("Idle")

# Handle movement and animation based on direction input
func handle_movement(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		velocity = direction * speed
		
		# Flip sprite based on movement direction
		if direction.x:
			animated_sprite.flip_h = direction.x < 0
	else:
		# Decelerate when not moving
		velocity.x = move_toward(velocity.x, 0, DECELERATION)
		velocity.y = move_toward(velocity.y, 0, DECELERATION)
	move_and_slide()

func execute_attack() -> void:  # Handle attack action
	await get_tree().create_timer(1.0)
	attack()  # Call the attack method implemented in the child classes
	

func attack() -> void:
	pass  # Implement attack logic in the child classes
