extends Character
class_name Enemy

@onready var turn_timer = Timer.new()
var turn_direction = 1

func _ready():
	super._ready()
	
	turn_timer.wait_time = 0.5
	turn_timer.one_shot = true
	add_child(turn_timer)
	
	turn_timer.timeout.connect(_on_turn_timeout)
	attack_rate_timer.timeout.connect(_on_enemy_attack_rate_timeout)	
	death_timer.timeout.connect(_on_enemy_death_timeout)
	
func _physics_process(delta):
	status_checker(delta)	
	update_animation_parameters()

func _on_adversary_ultimate_started():
	movement_enabled = false
	print("received ultimate started")
	animation_player.play(current_character.character_name + "_Idle")
	
func _on_adversary_ultimate_ended():
	movement_enabled = true
	print("received ultimate ended")
	
func _on_enemy_death_timeout():
	_on_death_timeout()
	SignalBus.enemy_died.emit(current_character) 
	queue_free()

func _on_enemy_attack_rate_timeout():
	_on_attack_rate_timeout()
	
func _on_turn_timeout():
	print("TURN TIMEOUT")
	scale.x = turn_direction
	
	movement_enabled = true

func status_checker(delta):
	if collision_data["in_detection_area"] == true:
		handle_movement(delta)
	if collision_data["in_attack_area"] == true:
		attack_and_adjust(delta)

func handle_movement(delta):
	if not movement_enabled:
		return
		
	if position.distance_to(adversary.global_position) > 40:
		# Walk to the player
		var distance_to_player = (adversary.global_position - position).normalized()
		position += distance_to_player * (current_character.speed) * delta
		
		# Play walking animation
		animation_player.queue(current_character.character_name + "_Idle")
		
		# Schedule the turn if the direction needs to change
		if distance_to_player.x > 0 and scale.x < 0:
			print("behind me1")
			if turn_timer.is_stopped():
				turn_timer.start()
				turn_direction = abs(scale.x)
				movement_enabled = false
		elif distance_to_player.x < 0 and scale.x > 0:
			print("behind me2")
			if turn_timer.is_stopped():
				turn_timer.start()
				turn_direction = -abs(scale.x)
				movement_enabled = false
	
func attack_and_adjust(delta):
	
	if not adversary:
		return
	
	# Adjust position to center the player in the hitbox
	var player_center_offset = adversary.global_position.x - position.x
	if abs(player_center_offset) > 90:  # Tolerance for centering
		var adjust_direction = sign(player_center_offset)  # Move left or right
		position.x += adjust_direction * (current_character.speed * delta)
	
	# Perform the attack logic
	attack()
	
func enemy_take_damage(damage: int):
	take_damage(damage)
