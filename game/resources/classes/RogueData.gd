extends CharacterData
class_name Rogue

func _init():
	print("Initializing Rogue")
	character_name = "Rogue"
	current_health = 150
	max_health = 150
	health_regen = 4
	health_regen_delay = 1
	speed = 200
	attack_damage = 5	
	animations = {
		"Attack": "res://resources/animations/Rogue_Attack.res",
		"Idle": "res://resources/animations/Rogue_Idle.res",
		"Walk": "res://resources/animations/Rogue_Walk.res"		
	}
	
func attack():
	print(character_name + "Attacks!!")

func activate_sp_ability():
	pass
	
func activate_ultimate():
	pass
