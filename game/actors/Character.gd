extends CharacterBody2D
class_name Character

@onready var animation_player: AnimationPlayer
@onready var animated_sprite: AnimatedSprite2D 
@onready var animation_tree: AnimationTree = $AnimationTree
var collision_data = {
	"in_detection_area": false,
	"in_attack_area": false
}
var attack_rate_timer: Timer
var death_timer: Timer
var ultimate_timer: Timer
var ultimate_cooldown_timer: Timer

var adversary: CharacterBody2D
var current_character: Resource
var character_datas = [ 
	preload("res://resources/Rogue.tres"), 
	preload("res://resources/Mage.tres"),
	preload("res://resources/Knight.tres")
]
var movement_enabled: bool = true
var teleport_mode_enabled: bool = false
var can_use_ultimate: bool = true

func _ready():

	animation_player = get_node("AnimationPlayer")
	animated_sprite = get_node("AnimationSprite2D")
	#animation_tree.active = true
	
	ultimate_cooldown_timer = Timer.new()
	ultimate_cooldown_timer.one_shot = true
	add_child(ultimate_cooldown_timer)
	
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
	
	ultimate_cooldown_timer.timeout.connect(_on_ultimate_cooldown_end)
	
func _process(delta):
	if teleport_mode_enabled and Input.is_action_just_pressed("left_mouse_click"):
		var mouse_position = get_global_mouse_position()
		global_position = mouse_position
		print("Mage teleported to: ", mouse_position)
		teleport_mode_enabled = false  # Exit teleport mode
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_attack_rate_timeout():
	if adversary and collision_data["in_attack_area"]: # If the player is still in attacking range
		print("Sending Damage")
		adversary.take_damage(current_character.attack_damage)
	movement_enabled = true
	animation_player.play(current_character.character_name + "_Idle")
	
func _on_ultimate_cooldown_end():
	can_use_ultimate = true

func _on_ultimate_timeout():
	animation_player.stop()
		
func _on_death_timeout():
	while current_character in character_datas:
		character_datas.erase(current_character)
	Debug.log("DYING PROCESS DONE")
	movement_enabled = true
	
func update_animation_parameters():
	animation_tree.set("parameters/conditions/idle", velocity == Vector2.ZERO)
	animation_tree.set("parameters/conditions/is_moving", velocity != Vector2.ZERO)
	animation_tree.set("parameters/conditions/attack", Input.is_action_just_pressed("left_mouse_click") )
	

func attack():
	if not attack_rate_timer.is_stopped():
		return # Avoid attacking if still on cooldown
	if not ultimate_timer.is_stopped():
		return
	movement_enabled = false
	# Start the attack rate timer
	attack_rate_timer.wait_time = current_character.attack_rate
	attack_rate_timer.start()
	# Play attacking animation	
	animation_player.play(current_character.character_name + "_Attack")
	
	
func ultimate_ability():
	if not can_use_ultimate:
		return
		
	if current_character.character_name == "Rogue":
		change_player_group($".", "player", "hidden")
		ultimate_timer.wait_time = current_character.ultimate_time
		ultimate_timer.start()
		animation_player.queue(current_character.character_name + "_Run")
		animation_player.queue(current_character.character_name + "_Run")
	elif current_character.character_name == "Mage":
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		print("Click to teleport to a position!")
		teleport_mode_enabled = true
		
		# Wait for a mouse click
		if Input.is_action_just_pressed("left_mouse_click"):
			var mouse_position = get_global_mouse_position()
			global_position = mouse_position
			print("Mage teleported to: ", mouse_position)
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	can_use_ultimate = false
	ultimate_cooldown_timer.wait_time = current_character.ultimate_cooldown
	ultimate_cooldown_timer.start()
		

func change_player_group(node: Node2D, old_groupname: String, new_groupname: String):
	if node.is_in_group(old_groupname):
		node.remove_from_group(old_groupname)
	if !node.is_in_group(new_groupname):
		node.add_to_group(new_groupname)

func take_damage(damage: int):
	if not death_timer.is_stopped():
		print("Character is dying, not taking anymore damage")
		
		return
	current_character.current_health -= damage
	print("Current Health: ", current_character.current_health)
	if current_character.current_health <= 0:
		print("dying")
		die()
	emit_health_signal()

func die():
	Debug.log("initiate dying process")
	movement_enabled = false
	animation_player.play(current_character.character_name + "_Death")
	# Start a death timer
	death_timer.wait_time = 1.0
	death_timer.start()
	current_character.current_health = 0.0
	emit_health_signal()
	
	
func emit_health_signal():
	SignalBus.health_changed.emit($".", current_character.current_health, current_character.max_health) 
