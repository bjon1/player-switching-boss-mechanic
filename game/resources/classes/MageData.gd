extends CharacterData
class_name Mage

@export var projectile_speed = 350

func _init():
	print("Initializing Mage")
	character_name = "Mage"
	current_health = 99
	max_health = 100
	health_regen = 3
	health_regen_delay = 1
	speed = 100
	attack_damage = 7
	animations = {
		"Attack": "res://resources/animations/Mage_Attack.res",
		"Idle": "res://resources/animations/Mage_Idle.res",
		"Walk": "res://resources/animations/Mage_Walk.res"		
	}
	
func get_attack_data() -> Dictionary:
	var fireball = load("res://scenes/fireball.tscn")
	print("Got " + character_name + "attack data")	
	return {
		"attack_type": "projectile",
		"projectile_scene": fireball,
		"projectile_speed": projectile_speed
	}
	
func activate_sp_ability():
	pass
	
func activate_ultimate():
	pass
