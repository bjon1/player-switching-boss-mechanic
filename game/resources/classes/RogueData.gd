extends Resource
class_name Rogue

@export var character_name: String = "Rogue"
@export var current_health: int = 150
@export var max_health: int = 150
@export var health_regen: float = 4
@export var health_regen_delay: float = 1
@export var speed: float = 200
@export var attack_damage: int = 30
@export var attack_rate: float = 0.6
@export var ultimate_time: float = 2
@export var ultimate_cooldown: float = 10
@export var animations: Dictionary = {
	"Attack": "res://resources/animations/Rogue_Attack.res",
	"Idle": "res://resources/animations/Rogue_Idle.res",
	"Walk": "res://resources/animations/Rogue_Walk.res"		
}

func _init():
	print("Initializing Rogue")	
	
func get_attack_data() -> Dictionary:
	print("Got " + character_name + "attack data")	
	return {
		"attack_type": "melee",
	}
	
func activate_sp_ability():
	pass
	
func activate_ultimate():
	pass
