extends CharacterData
class_name Rogue

func _init():
	print("Initializing Rogue")
	character_name = "Rogue"
	current_health = 150
	max_health = 150
	health_regen = 4
	health_regen_delay = 1
	speed = 175
	attack_damage = 5	
	#@export var character_icon: Texture
	#@export var animations: Dictionary 
	
func attack():
	print(character_name + "Attacks!!")

func activate_sp_ability():
	pass
	
func activate_ultimate():
	pass
