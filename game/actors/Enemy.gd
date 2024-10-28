extends Character
class_name Enemy


func _ready():
	super._ready()
	attack_rate_timer.timeout.connect(_on_enemy_attack_rate_timeout)	
	death_timer.timeout.connect(_on_enemy_death_timeout)
	
func _on_enemy_death_timeout():
	_on_death_timeout()
	SignalBus.enemy_died.emit(current_character) 
	queue_free()

func _on_enemy_attack_rate_timeout():
	_on_attack_rate_timeout()

func _physics_process(delta):
	status_checker(delta)	

func status_checker(delta):
	if collision_data["in_detection_area"] == true:
		handle_movement(delta)
	if collision_data["in_attack_area"] == true:
		attack()
	
func handle_movement(delta):
	if position.distance_to(adversary.global_position) > 40:
		
		if not movement_enabled:
			return
		
		# Walk to the player
		var distance_to_player = (adversary.global_position - position).normalized()
		position += distance_to_player * (current_character.speed) * delta
		
		# Play walking animation
		animation_player.queue(current_character.character_name + "_Walk")
		
		# Flip the enemy based on the movement direction
		if distance_to_player.x > 0 and scale.x < 0:
			scale.x = abs(scale.x)
		elif distance_to_player.x < 0 and scale.x > 0:
			scale.x = -abs(scale.x)

func enemy_attack():
	attack()
	
func enemy_take_damage(damage: int):
	take_damage(damage)
