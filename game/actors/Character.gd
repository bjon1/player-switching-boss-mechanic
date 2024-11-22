extends CharacterBody2D
class_name Character

@onready var animation_player: AnimationPlayer
@onready var animated_sprite: AnimatedSprite2D 
var collision_data = {
	"in_detection_area": false,
	"in_attack_area": false
}
var attack_rate_timer: Timer
var death_timer: Timer
var ultimate_timer: Timer
var adversary: CharacterBody2D
var current_character: Resource
var character_datas = [ 
	preload("res://resources/Rogue.tres"), 
	preload("res://resources/Mage.tres"),
	preload("res://resources/Knight.tres")
]
var movement_enabled: bool = true
func _ready():

	animation_player = get_node("AnimationPlayer")
	animated_sprite = get_node("AnimationSprite2D")
	
	# Add a timer to control attack rate
	attack_rate_timer = Timer.new()
	attack_rate_timer.one_shot = true
	add_child(attack_rate_timer)
	
	# Add a timer to control death 
	death_timer = Timer.new()
	death_timer.one_shot = true
	add_child(death_timer)
	
	ultimate_timer = Timer.new()
	ultimate_timer.one_shot = true
	add_child(ultimate_timer)

func _on_attack_rate_timeout():
	if adversary and collision_data["in_attack_area"]: # If the player is still in attacking range
		print("Sending Damage")
		adversary.take_damage(current_character.attack_damage)
		movement_enabled = true
	animation_player.play(current_character.character_name + "_Idle")
	
func _on_ultimate_timeout():
	animation_player.stop()
		
func _on_death_timeout():
	while current_character in character_datas:
		character_datas.erase(current_character)
	print("DYING PROCESS DONE")
	movement_enabled = true
	

func attack():

	movement_enabled = false
	if not attack_rate_timer.is_stopped():
		return # Avoid attacking if still on cooldown
	# Start the attack rate timer
	attack_rate_timer.wait_time = current_character.attack_rate
	attack_rate_timer.start()
	# Play attacking animation	
	animation_player.play(current_character.character_name + "_Attack")
	
func ultimate_ability():
	ultimate_timer.wait_time = 3
	ultimate_timer.start()
	animation_player.queue(current_character.character_name + "_Run")
	animation_player.queue(current_character.character_name + "_Run")
	animation_player.queue(current_character.character_name + "_Run")
	

func take_damage(damage: int):
	if not death_timer.is_stopped():
		print("Character is dying, not taking anymore damage")
		return
	current_character.current_health -= damage
	print("Current Health: ", current_character.current_health)
	if current_character.current_health <= 0:
		print("dying")
		die()

func die():
	print("initiate dying process")
	movement_enabled = false
	animation_player.play(current_character.character_name + "_Death")
	# Start a death timer
	death_timer.wait_time = 1.5
	death_timer.start()
