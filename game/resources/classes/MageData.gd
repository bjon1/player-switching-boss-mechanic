extends CharacterData
class_name Mage


func _init():
	print("Initializing Mage")
	character_name = "Mage"
	current_health = 99
	max_health = 100
	health_regen = 3
	health_regen_delay = 1
	speed = 100
	attack_damage = 7
	#@export var character_icon: Texture
	#@export var animations: Dictionary 
	

func attack():
	
	print(character_name + " Attacks!")
	

func activate_sp_ability():
	pass
	
func activate_ultimate():
	pass
