extends Resource
class_name Knight

@export var character_name: String = "Knight"
@export var current_health: int = 180
@export var max_health: int = 180
@export var health_regen: float = 5
@export var health_regen_delay: float = 1
@export var speed: float = 150
@export var attack_damage: int = 7
@export var attack_rate: float = 0.7
@export var animations: Dictionary = {
	"Attack": "res://resources/animations/Knight_Attack.res",
	"Idle": "res://resources/animations/Knight_Idle.res",
	"Walk": "res://resources/animations/Knight_Walk.res"		
}

func _init():
	print("Initializing Knight")	
	
func get_attack_data() -> Dictionary:
	print("Got " + character_name + "attack data")	
	return {
		"attack_type": "melee",
	}
	
func activate_sp_ability():
	pass
	
func activate_ultimate():
	pass
