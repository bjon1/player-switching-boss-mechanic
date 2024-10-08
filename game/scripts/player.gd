extends CharacterBody2D

const SPEED: float = 200.0
const DECELERATION: float = 50.0  # Optional deceleration constant

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_attacking: bool = false

func _physics_process(delta: float) -> void:
	var movement_input = get_input()
	handle_movement_and_animation(movement_input)
	move_and_slide()
	
	if Input.is_action_just_pressed("attack"):
		attack()

# Separate the input handling logic
func get_input() -> Vector2:
	var direction_x: float = Input.get_axis("move_left", "move_right")
	var direction_y: float = Input.get_axis("move_up", "move_down")
	return Vector2(direction_x, direction_y).normalized()

# Handle movement and animation in a single function
func handle_movement_and_animation(direction: Vector2) -> void:
	if is_attacking:
		return
	
	# Adjust velocity based on input
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		animated_sprite.play("Walk")
		if direction.x:
			animated_sprite.flip_h = direction.x < 0
	else:
		# Deceleration
		velocity.x = move_toward(velocity.x, 0, DECELERATION)
		velocity.y = move_toward(velocity.y, 0, DECELERATION)
		animated_sprite.stop()

func attack() -> void:
	pass