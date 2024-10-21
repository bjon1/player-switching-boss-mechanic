extends Enemy
class_name EnemyKnight

@export var player = null
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var data = preload("res://resources/Knight.tres")
var attack_rate_timer: Timer

var collision_data = {
	"in_detection_area": false,
	"in_attack_area": false
}

func _ready():
	# Add a timer to control attack rate
	attack_rate_timer = Timer.new()
	attack_rate_timer.one_shot = true
	add_child(attack_rate_timer)
	attack_rate_timer.timeout.connect(_on_attack_rate_timeout)	

func _physics_process(delta):
	status_checker(delta)	

func status_checker(delta):
	if collision_data["in_detection_area"] == true:
		handle_movement(delta)
	if collision_data["in_attack_area"] == true:
		attack()
	
func handle_movement(delta):
	if position.distance_to(player.global_position) > 40:
		
		# Walk to the player
		var distance_to_player = (player.global_position - position).normalized()
		position += distance_to_player * (data.speed - 80) * delta
		
		# Play walking animation
		animation_player.queue(data.character_name + "_Walk")
		
		# Flip the enemy based on the movement direction
		if distance_to_player.x > 0 and scale.x < 0:
			scale.x = abs(scale.x)
		elif distance_to_player.x < 0 and scale.x > 0:
			scale.x = -abs(scale.x)

func _on_attack_rate_timeout():
	if player: # If the player is still in attacking range
		player.take_damage(data.attack_damage)
	# Get attack data and execute attack logic
	animation_player.play(data.character_name + "_Idle")	

func _on_detection_area_body_entered(body) -> void:
	if body.is_in_group("player"):
		print("Detection Area Entered")
		player = body
		collision_data["in_detection_area"] = true
	
func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		print("Detection Area Exited")
		player = null
		collision_data["in_detection_area"] = false
	animation_player.play(data.character_name + "_Idle")	
		
func _on_attack_area_body_entered(body: Node2D) -> void:
	if body == player:
		print("Attack Area Entered")
		collision_data["in_attack_area"] = true

func _on_attack_area_body_exited(body: Node2D) -> void:
	if body == player:
		print("Attack Area Exited")
		collision_data["in_attack_area"] = false
	animation_player.play(data.character_name + "_Idle")	
	
func attack():
	
	if not attack_rate_timer.is_stopped():
		return #Avoid attacking if still on cooldown
		
	# Disable input and start the timer for attack cooldown
	attack_rate_timer.wait_time = data.attack_rate
	attack_rate_timer.start()
	
	# Play attacking animation	
	animation_player.stop()
	animation_player.play(data.character_name + "_Attack")
	

		
		
