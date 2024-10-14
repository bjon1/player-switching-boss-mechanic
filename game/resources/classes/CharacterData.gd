extends Resource
class_name CharacterData

@export var character_name: String
@export var current_health: int 
@export var max_health: int 
@export var health_regen: float
@export var health_regen_delay: float
@export var speed: float
@export var attack_damage: int

@export var character_icon: Texture
@export var animations: Dictionary 

func attack():
	print("Attacked")
	
func activate_sp_ability():
	pass
	
func activate_ultimate():
	pass
